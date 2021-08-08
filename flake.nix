{
  description = "Ambroisie's blog";

  inputs = {
    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";
      ref = "master";
      inputs = {
        flake-utils.follows = "futils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, futils, nixpkgs, pre-commit-hooks } @ inputs:
    futils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks = {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;

            hooks = {
              nixpkgs-fmt = {
                enable = true;
              };

              markdown-lint = {
                enable = true;

                name = "Lint each post's markdown";

                entry =
                  let
                    pkg = pkgs.nodePackages.markdownlint-cli;
                  in
                  "${pkg}/bin/markdownlint";

                types = [ "markdown" ];
              };
            };
          };
        };

        devShell = pkgs.mkShell {
          name = "blog";

          buildInputs = with pkgs; [
            gnumake
            hugo
          ];

          inherit (self.checks.${system}.pre-commit) shellHook;
        };
      }
    );
}
