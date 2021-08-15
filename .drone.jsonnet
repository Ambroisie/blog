local Pipeline(isDev) = {
  kind: "pipeline",
  type: "exec",
  name: if isDev then "Deploy to dev" else "Deploy to prod",
  # Dev ignores "master", prod only triggers on "master"
  trigger: { branch: { [if isDev then "exclude" else "include"]: [ "main" ] } },
  steps: [
    {
      # We want to clone the submodules, which isn't done by default
      name: "submodules",
      commands: [
        "git submodule update --recursive --init",
      ]
    },
    {
      # Include pre-commit checks, which include markdownlint
      name: "check",
      commands: [
        "nix flake check",
      ],
    },
    {
      # If dev, include drafts and future articles, change base URL
      name: "build",
      commands: [
        "nix develop -c make " + if isDev then "build-dev" else "build-prod",
      ],
    },
    {
      name: "deploy",
      commands: [
        "nix run github:ambroisie/nix-config#drone-scp",
      ],
      environment: {
        SCP_SOURCE: "public/*",
        TAR_STRIP_COMPONENTS: 1, # Remove 'public/' suffix from file paths
        SCP_RM: true, # Remove previous files from target directory
        SCP_HOST: { from_secret: "ssh_host" },
        SCP_TARGET: { from_secret: "ssh_target" + if isDev then "_dev" else "" },
        SCP_USERNAME: { from_secret: "ssh_user" },
        SCP_KEY: { from_secret: "ssh_key" },
        SCP_PORT: { from_secret: "ssh_port" },
      },
    },
    {
      name: "notify",
      commands: [
        "nix run github:ambroisie/matrix-notifier",
      ],
      environment: {
        ADDRESS: { from_secret: "matrix_homeserver" },
        ROOM: { from_secret: "matrix_roomid" },
        USER: { from_secret: "matrix_username" },
        PASS: { from_secret: "matrix_password" },
      },
      when: { status: [ "failure", "success", ] },
    },
  ]
};


[
  Pipeline(false),
  Pipeline(true),
]
