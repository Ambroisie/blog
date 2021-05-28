{
  description = "Ambroisie's blog";

  inputs = {
    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };

    # https://nixpk.gs/pr-tracker.html?pr=124808
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  outputs = { self, futils, nixpkgs } @ inputs:
    futils.lib.eachSystem futils.lib.allSystems (system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShell = pkgs.mkShell {
          name = "blog";

          buildInputs = with pkgs; [
            gnumake
            hugo
          ];
        };
      }
    );
}
