{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jovian.decky-loader;
  jsonFormat = pkgs.formats.json { };
in
{
  options.jovian.decky-loader =
    let
      pluginOpt = { name, ... }: {
        options = {
          src = mkOption {
            type = types.path;
          };
        };
      };
    in
    {
      plugins = mkOption {
        description = "Plugins to install";
        type = with types; attrsOf (submodule pluginOpt);
        default = { };
      };
    };
  config =
    let
      dataPath = config.jovian.decky-loader.stateDir;
      pluginPath = "${dataPath}/plugins";
    in
    {
      system.activationScripts.installDeckyPlugins = ''
        # SETUP
        mkdir -p "${pluginPath}"
        find "${pluginPath}" -maxdepth 1 -type l -delete

        # PLUGINS
        ${
          pkgs.lib.concatStringsSep "\n" (flip mapAttrsToList cfg.plugins (
            name: plugin: 
            ''
              ln -snf "${plugin.src}" "${pluginPath}/${name}"
            ''
          ))
        }
      '';
    };
}
