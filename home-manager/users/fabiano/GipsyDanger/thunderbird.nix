{ lib, pkgs, ... }:
with lib;
let
  general = builtins.fromJSON (builtins.readFile ../../../../sensitive/general.json);

  radicale = id: "https://radicale.${general.domain}/fabiano/${id}/";
in
{
  programs.thunderbird = {
    enable = true;

    profiles.main = {
      isDefault = true;

      userChrome = ''
        /* Hide the Tasks and Chat buttons in the spaces toolbar. */
        #tasksButton,
        #chatButton {
          display: none !important;
        }
      '';

      calendarAccountsOrder = [
        "General"
        "Family"
        "House"
        "Routine"
        "[Maitê] General"
      ];
    };

    settings = {
      # Not exposed in Settings on Linux, but read at runtime (messenger.js).
      "mail.closeToTray" = true;
      "mail.closeToTray.startInTray" = true;

      "mail.chat.enabled" = false;
      "mail.spellcheck.inline" = true;
      "mailnews.start_page.enabled" = false;
      "mailnews.message_display.disable_remote_image" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
  };

  accounts.email.accounts.personal = {
    primary = true;
    flavor = "gmail.com";

    address = general.emails.personal;
    userName = general.emails.personal;
    realName = "Fabiano Honorato";

    thunderbird.enable = true;
  };

  accounts.calendar = {
    basePath = ".calendar";

    accounts = {
      "General" = {
        primary = true;
        remote = {
          type = "caldav";
          url = radicale "cc31c855-a574-4bc2-8260-e7d843e98efa";
          userName = "fabiano";
        };
        thunderbird = {
          enable = true;
          color = "#3584e4";
        };
      };

      "Family" = {
        remote = {
          type = "caldav";
          url = radicale "e7a2da64-508e-9017-44dc-0f2314860960";
          userName = "fabiano";
        };
        thunderbird = {
          enable = true;
          color = "#33d17a";
        };
      };

      "House" = {
        remote = {
          type = "caldav";
          url = radicale "cf1af35d-6687-f649-f8f8-10023cca1ede";
          userName = "fabiano";
        };
        thunderbird = {
          enable = true;
          color = "#ff7800";
        };
      };

      "Routine" = {
        remote = {
          type = "caldav";
          url = radicale "3e4a9942-5417-e7e0-ff9f-4eee35811391";
          userName = "fabiano";
        };
        thunderbird = {
          enable = true;
          color = "#9141ac";
        };
      };

      "[Maitê] General" = {
        remote = {
          type = "caldav";
          url = radicale "6d360769-b3a7-4b6f-7828-c66642b6bad4";
          userName = "fabiano";
        };
        thunderbird = {
          enable = true;
          color = "#e01b24";
        };
      };
    };
  };

  accounts.contact = {
    basePath = ".contacts";

    accounts = {
      "General" = {
        remote = {
          type = "carddav";
          url = radicale "6d2e7b07-3604-469d-10af-d25d7c9e60f3";
          userName = "fabiano";
        };
        thunderbird.enable = true;
      };

      "Business" = {
        remote = {
          type = "carddav";
          url = radicale "61d12c2e-611e-60cf-3f42-c0582cc6f835";
          userName = "fabiano";
        };
        thunderbird.enable = true;
      };
    };
  };
}
