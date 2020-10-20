local Pipeline(isDev) = {
  kind: "pipeline",
  name: if isDev then "deploy-dev" else "deploy-prod",
  # Dev ignores "master", prod only triggers on "master"
  trigger: { branch: { [if isDev then "exclude" else "include"]: [ "master" ] } },
  # We want to clone the submodules, which isn't done by default
  clone: { disable: true },
  steps: [
    {
      name: "clone",
      image: "plugins/git",
      recursive: true,
    },
    {
      name: "markdownlint",
      image: "06kellyjac/markdownlint-cli",
      commands: [
        "markdownlint --version",
        "markdownlint content/",
      ],
    },
    {
      name: "build",
      image: "klakegg/hugo",
      commands: [
        "hugo version",
        # If dev, include drafts and future articles, change base URL
        "hugo --minify" + if isDev then " -D -F -b https://dev.belanyi.fr" else "",
      ],
      [if !isDev then "environment"]: { HUGO_ENV: "production" }
    },
    {
      name: "deploy",
      image: "appleboy/drone-scp",
      settings: {
        source: "public/*",
        strip_components: 1, # Remove 'public/' suffix from file paths
        rm: true, # Remove previous files from target directory
        host: { from_secret: "ssh_host" },
        target: { from_secret: "ssh_target" + if isDev then "_dev" else "" },
        username: { from_secret: "ssh_user" },
        key: { from_secret: "ssh_key" },
        port: { from_secret: "ssh_port" },
      },
    },
    {
      name: "notify",
      image: "plugins/matrix",
      settings: {
        homeserver: { from_secret: "matrix_homeserver" },
        roomid: { from_secret: "matrix_roomid" },
        username: { from_secret: "matrix_username" },
        password: { from_secret: "matrix_password" },
      },
      trigger: { status: [ "failure", "success", ] },
    },
  ]
};


[
  Pipeline(false),
  Pipeline(true),
]
