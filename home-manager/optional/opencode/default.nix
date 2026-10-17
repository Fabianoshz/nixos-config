{ config, lib, ... }:
let
  skillsDir = ./skills;
  skillNames = lib.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)
  );
  skillFiles = lib.listToAttrs (
    map
      (name: {
        name = ".config/opencode/skills/${name}";
        value = {
          source = skillsDir + "/${name}";
          recursive = true;
        };
      })
      skillNames
  );
in
{
  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    attention = {
      enabled = true;
      notifications = true;
      sound = false;
    };
  };

  home.file = {
    ".config/opencode/opencode.jsonc".source = ./opencode.jsonc;
  } // skillFiles;
}
