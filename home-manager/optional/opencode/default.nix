{ ... }:
{
  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    attention = {
      enabled = true;
      notifications = true;
      sound = false;
    };
  };
}
