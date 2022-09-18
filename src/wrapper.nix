# Remove when https://github.com/NixOS/nixpkgs/pull/191679 lands.
{ pkgs }:

pkgs.lib.makeOverridable ({
  completionDirs ? [],
  functionDirs ? [],
  confDirs ? [],
  pluginPkgs ? [],
  localConfig ? "",
  shellAliases ? {}
}:

let
  inherit (pkgs) lib fish;

  aliasesStr = builtins.concatStringsSep "\n"
      (lib.mapAttrsToList (k: v: "alias ${k} ${lib.escapeShellArg v}") shellAliases);

  shellAliasesFishConfig = pkgs.writeTextFile {
    name = "wrapfish.aliases.fish";
    destination = "/share/fish/vendor_conf.d/aliases.fish";
    text = ''
      status --is-interactive; and begin
        # Aliases
        ${aliasesStr}
      end
    '';
  };

  localFishConfig = pkgs.writeTextFile {
    name = "wrapfish.local.fish";
    destination = "/share/fish/vendor_conf.d/config.local.fish";
    text = localConfig;
  };

  vendorDir = kind: plugin: "${plugin}/share/fish/vendor_${kind}.d";
  complPath = completionDirs ++ map (vendorDir "completions") pluginPkgs;
  funcPath = functionDirs ++ map (vendorDir "functions") pluginPkgs;
  confPath = confDirs
    ++ (map (vendorDir "conf") pluginPkgs)
    ++ (map (vendorDir "conf") [ localFishConfig shellAliasesFishConfig ]);

in pkgs.writeShellScriptBin "fish" ''
  ${fish}/bin/fish --init-command "
    set --prepend fish_complete_path ${lib.escapeShellArgs complPath}
    set --prepend fish_function_path ${lib.escapeShellArgs funcPath}
    set --local fish_conf_source_path ${lib.escapeShellArgs confPath}
    for c in \$fish_conf_source_path/*; source \$c; end
  " "$@"
'')
