{ lib, ... }:
{
  # Dynamic Profile for the hotkey window; "Rewritable" false prevents iTerm2 from overwriting this managed file
  home.file."Library/Application Support/iTerm2/DynamicProfiles/hotkey-window.json".text = builtins.toJSON {
    Profiles = [
      {
        Name = "Hotkey Window";
        Guid = "hotkey-window-fabiano";
        "Dynamic Profile Parent Name" = "Default";
        "Has Hotkey" = true;
        "HotKey Characters" = "t";
        "HotKey Characters Ignoring Modifiers" = "t";
        "HotKey Key Code" = 17;
        "HotKey Modifier Flags" = 1310720; # Ctrl+Cmd
        "HotKey Window Animates" = true;
        "HotKey Window AutoHides" = true;
        "HotKey Window Floats" = false;
        "HotKey Window Reopens On Activation" = false;
        "HotKey Activated By Modifier" = false;
        "HotKey Modifier Activation" = 0;
        "HotKey Window Dock Click Action" = 0;
        "Left Option Key Sends" = 2; # Esc+ (Meta), required for Alt+Arrow in tmux
        Style = 6; # Full-Width Top of Screen
        Rows = 20;
        Rewritable = false;
      }
    ];
  };

  # Only restore the hotkey window on startup, suppressing the default blank terminal
  home.activation.iterm2Prefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults write com.googlecode.iterm2 OpenTmuxWindowsIn -int 2
    run /usr/bin/defaults write com.googlecode.iterm2 OpenArrangementAtStartup -bool false
    run /usr/bin/defaults write com.googlecode.iterm2 OpenNoWindowsAtStartup -bool true
    run /usr/bin/defaults write com.googlecode.iterm2 NSQuitAlwaysKeepsWindows -bool false
  '';

  # Start iTerm2 hidden at login so the hotkey (Ctrl+Cmd+T) is available immediately
  launchd.agents.iterm2-startup = {
    enable = true;
    config = {
      ProgramArguments = [ "/usr/bin/open" "-j" "-a" "iTerm" ];
      RunAtLoad = true;
    };
  };
}
