{ nixpkgs, pkgs, system, inputs }:

let
  git = import ./git.nix { inherit pkgs; };

  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    ll = "exa -lha";
    cat = "bat";
    ls = "exa";
    grep = "rg";
    man = "batman";
    hw = "hello";
  };
  localConfig = ''
    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
  '';

  # Remove when https://github.com/NixOS/nixpkgs/pull/191679 lands.
  wrapFish = import ./wrapper.nix { inherit pkgs; };
in pkgs.buildEnv {
  name = "fish";

  paths = [
    (wrapFish {
      inherit shellAliases localConfig;
      pluginPkgs = [
        inputs.z
        pkgs.fishPlugins.foreign-env
        pkgs.fishPlugins.pure
      ];
    })
    pkgs.any-nix-shell
    pkgs.bat
    pkgs.bat-extras.batman
    pkgs.bottom
    pkgs.cachix
    pkgs.difftastic
    pkgs.direnv
    pkgs.exa
    pkgs.hello
    git
    pkgs.nix-direnv
    pkgs.ripgrep
  ];
}
