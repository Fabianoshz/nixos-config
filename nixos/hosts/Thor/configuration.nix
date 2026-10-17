{ config, pkgs, lib, inputs, ... }:

let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  thor.user = "fabiano";
  thor.fex.enable = true;

  users.users.fabiano = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ general.ssh.general ];
  };

  services.openssh.enable = true;
  networking.hostName = "Thor";
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    vim
    htop
    gamescope
  ];

  nixpkgs.overlays = [
    (final: prev: {
      libretro = prev.libretro // {
        ppsspp = prev.libretro.ppsspp.overrideAttrs (old: {
          meta = old.meta // {
            broken = false;
            badPlatforms = [ ];
          };
        });
      };

      gamescope = prev.gamescope.overrideAttrs (old: {
        src = inputs.gamescope-thor;
      });
    })
  ];

  system.stateVersion = "26.05";
}
