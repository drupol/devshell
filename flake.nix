{
  description = "Nix development shell";

  inputs = {
    nixpkgs.url = "github:/nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";

    # Fish plugins
    z = { url = "github:jethrokuan/z"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          (final: prev: {
            master = import inputs.nixpkgs-master {
              inherit (final) config;
              system = "${prev.system}";
            };
          })
        ];

        pkgs = import nixpkgs {
          inherit overlays system;
        };

        shell = import ./src/fish.nix { inherit nixpkgs pkgs system inputs; };
      in rec
      {
        # nix shell, nix run
        packages = {
          default = shell;
        };

        # nix develop, nix-direnv
        devShells = builtins.mapAttrs (name: value: pkgs.mkShellNoCC { inherit name; buildInputs = [value];}) packages;
      }
    );
}
