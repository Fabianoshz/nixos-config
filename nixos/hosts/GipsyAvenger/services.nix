{ pkgs, ... }:
{
  services = {
    inputplumber.enable = true;

    openssh.enable = true;
    desktopManager.plasma6.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        back_button_timeout = 2000;
      };
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Desktop";
          }
        ];
      };
    };
  };
}
