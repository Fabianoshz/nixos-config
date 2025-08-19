{ inputs, pkgs, ... }:
{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      # plasma-apply-desktoptheme --list-themes
      theme = "breeze-dark";
      # plasma-apply-colorscheme --list-schemes
      colorScheme = "Darkly";
      # lookandfeeltool --list
      # lookAndFeel = "org.kde.breezedark.desktop";

      windowDecorations = {
        theme = "Darkly";
        library = "org.kde.darkly";
      }; 

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
        location = "top";
        height = 32;
        widgets = [   
	  {
          
	  kickerdash = {
	      icon = "applications-all";
	    };
	  }
          {
            iconTasks = {
              appearance = {
	        fill = false;
                rows.multirowView = "never";
		iconSpacing = "medium";
              };
              behavior = {
                grouping.method = "none";
                sortingMethod = "manually";
              };
              iconsOnly = true;
            };
          }
          "org.kde.plasma.panelspacer"
          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
	      date = {
                enable = true;
	        position = "besideTime";
		format = {
		  custom = "ddd d MMM";
		};
              };
	      time = {
                format = "24h";
	        showSeconds = "always";
	      };
            };
          }
          "org.kde.plasma.panelspacer"
	  "plasmusic-toolbar"
	  "org.kde.plasma.marginsseparator"
          {
	    systemTray = {
	      icons.spacing = "medium";
	      items = {
	        showAll = false;
		hidden = [
                  "org.kde.plasma.addons.katesessions"
		  "org.kde.plasma.keyboardlayout"
		];
		shown = [
		  "org.kde.plasma.brightness"
		  "org.kde.plasma.networkmanagement"
		  "org.kde.plasma.volume"
		  "org.kde.kdeconnect"
		  "org.kde.plasma.notifications"
		  "org.kde.plasma.battery"
		];
		extra = [
		  "org.kde.plasma.brightness"
		  "org.kde.plasma.networkmanagement"
		  "org.kde.plasma.volume"
		  "org.kde.kdeconnect"
		  "org.kde.plasma.notifications"
		  "org.kde.plasma.battery"
		];
	      };
	    };
	  }
        ];
      }
    ];    

    configFile = {
      # Krunner
      "krunnerrc"."General"."FreeFloating" = true;
      "krunnerrc"."Plugins"."krunner_appstreamEnabled" = false;
      "krunnerrc"."Plugins"."krunner_bookmarksrunnerEnabled" = true;
      "krunnerrc"."Plugins"."krunner_charrunnerEnabled" = false;
      "krunnerrc"."Plugins"."krunner_dictionaryEnabled" = false;
      "krunnerrc"."Plugins"."krunner_katesessionsEnabled" = false;
      "krunnerrc"."Plugins"."krunner_killEnabled" = false;
      "krunnerrc"."Plugins"."krunner_konsoleprofilesEnabled" = false;
      "krunnerrc"."Plugins"."krunner_kwinEnabled" = false;
      "krunnerrc"."Plugins"."krunner_placesrunnerEnabled" = false;
      "krunnerrc"."Plugins"."krunner_plasma-desktopEnabled" = false;
      "krunnerrc"."Plugins"."krunner_powerdevilEnabled" = true;
      "krunnerrc"."Plugins"."krunner_recentdocumentsEnabled" = false;
      "krunnerrc"."Plugins"."krunner_servicesEnabled" = true;
      "krunnerrc"."Plugins"."krunner_sessionsEnabled" = true;
      "krunnerrc"."Plugins"."krunner_shellEnabled" = false;
      "krunnerrc"."Plugins"."krunner_spellcheckEnabled" = false;
      "krunnerrc"."Plugins"."krunner_systemsettingsEnabled" = false;
      "krunnerrc"."Plugins"."krunner_webshortcutsEnabled" = false;
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
          size = 12;
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

  home.file = {
    ".config/yakuakerc" = {
      text = ''
        [Animation]
        Frames=20

        [Desktop Entry]
        DefaultProfile=Personal.profile

        [Dialogs]
        FirstRun=false

        [Notification Messages]
        ShowPasteHugeTextWarning=false

        [Window]
        Height=100
        ShowTabBar=false
        Width=100
      '';
    };
  };
}
