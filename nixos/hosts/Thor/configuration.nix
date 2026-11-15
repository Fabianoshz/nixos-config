{ config, pkgs, lib, inputs, ... }:

let
  general = builtins.fromJSON (builtins.readFile ../../../sensitive/general.json);
in
{
  imports = [
    ./decky-loader.nix
    ./inputplumber
    ./steam-storage.nix
  ];

  thor.user = "fabiano";
  thor.storage = "internal";

  home-manager.startAsUserService = true;

  users.users.fabiano = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ general.ssh.general ];
  };

  systemd.services."drkonqi-coredump-processor@".enable = false;
  systemd.user.sockets.drkonqi-coredump-launcher.enable = false;

  services.orca.enable = false;
  services.speechd.enable = false;

  networking = {
    hostName = lib.mkForce "Thor";

    firewall = {
      enable = true;
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
        { from = 3389; to = 3389; } # RDP
        { from = 8384; to = 8384; } # Syncthing web
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; } # KDE Connect
        { from = 21027; to = 21027; } # Syncthing
        { from = 22000; to = 22000; } # Syncthing
      ];
    };
  };

  services.openssh.enable = true;
  time.timeZone = lib.mkForce "America/Sao_Paulo";
  # Steam's sandbox hides the zone name behind /.host-etc/localtime (UI shows Etc/Unknown).
  environment.sessionVariables.TZ = config.time.timeZone;
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";

  # nix-on-thor's legacy shell hook is incompatible with systemd initrd.
  boot.initrd.postDeviceCommands = lib.mkForce "";

  systemd.user.services.thor-gamescope.environment.GAMESCOPE_BOTTOM_SCREEN_TITLES =
    "^RetroArch - Screen [2-9]$";

  services.udev.extraHwdb = ''
    evdev:input:b0003v2020p3001*
     EVDEV_ABS_02=240:1552
     EVDEV_ABS_05=240:1552
  '';

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  boot.kernel.sysctl."vm.swappiness" = 180;

  environment.systemPackages = with pkgs; [
    vim
    htop
    gamescope

    (callPackage ../../../pkgs/RetroLauncher { })
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
    })
  ];

  system.stateVersion = lib.mkForce "26.05";
}
