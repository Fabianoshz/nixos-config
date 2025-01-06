{ plasma-manager, pkgs, ... }:
{
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Breeze Dark";

      cursor = {
        theme = "Breeze";
      };
    };
 
    spectacle.shortcuts = {
      captureActiveWindow = "";
      captureCurrentMonitor = "";
      captureEntireDesktop = "";
      captureRectangularRegion = "Ctrl+Alt+A";
      captureWindowUnderCursor = "";
      launch = "";
      launchWithoutCapturing = "";
    };

    configFile = {
      "krunnerrc"."General"."FreeFloating" = true;
      "krunnerrc"."Plugins"."vscode_runnerEnabled" = true;
      "krunnerrc"."Plugins"."krunner_bookmarksrunnerEnabled" = true;
      "krunnerrc"."Plugins"."krunner_servicesEnabled" = true;
    };

    shortcuts = {
      "plasmashell"."toggle do not disturb" = "Ctrl+Alt+Q";
      "yakuake"."toggle-window-state" = "Ctrl+Alt+T";
      "services/org.kde.krunner.desktop"."_launch" = "Ctrl+Space";
    };
  };

  programs.konsole = {
    enable = true;
  
    defaultProfile = "Personal";

    profiles = {
      "Personal" = {
        colorScheme = "Transparent";
        command = "${pkgs.zsh}/bin/zsh";
        font = {
          name = "MesloLGS NF";
          size = 14;
        };
        extraConfig = {
          Scrolling = {
            HistoryMode = 2;
          };
          Appearance = {
            BoldIntense = true;
          };
        };
      };
    };

    customColorSchemes = {
      "Transparent" = ./Transparent.colorscheme;
    };
  };
}
