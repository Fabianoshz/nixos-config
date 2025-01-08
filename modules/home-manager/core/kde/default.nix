{ plasma-manager, pkgs, ... }:
{
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      # plasma-apply-desktoptheme --list-themes
      theme = "Nordic-darker";
      # plasma-apply-colorscheme --list-schemes
      colorScheme = "NordicDarker";
      # lookandfeeltool --list
      lookAndFeel = "org.kde.breezedark.desktop";

      iconTheme = "Papirus-Dark";

      cursor = {
        # plasma-apply-cursortheme --list-themes
        theme = "Nordic-cursors";
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

      panels = [
        {
          location = "bottom";
          height = 48;
          widgets = [   
            "org.kde.plasma.kickoff"
            {
              iconTasks = {
                iconsOnly = true;
                appearance.rows.multirowView = "never";
                behavior = {
                  grouping.method = "none";
                  sortingMethod = "manually";
                };
              };
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            {  
              digitalClock = {
                date.enable = false;  
                time.format = "24h";
                calendar.firstDayOfWeek = "monday";
              };
            }
          ];
        }
      ];    

    configFile = {
      "krunnerrc"."General"."FreeFloating" = true;
      "krunnerrc"."Plugins"."vscode_runnerEnabled" = true;
      "krunnerrc"."Plugins"."krunner_bookmarksrunnerEnabled" = true;
      "krunnerrc"."Plugins"."krunner_servicesEnabled" = true;

      "kwinrc"."org.kde.kdecoration2"."BorderSizeAuto" = false;
      "kwinrc"."org.kde.kdecoration2"."theme" = "__aurorae__svg__Nordic";
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
