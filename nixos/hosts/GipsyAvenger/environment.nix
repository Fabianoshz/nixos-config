{ pkgs, ... }:
{
  environment = {
    systemPackages = [
      pkgs.appimage-run
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.python3
      pkgs.vim
      pkgs.wget
    ];

    plasma6.excludePackages = with pkgs.libsForQt5; [
      elisa
      oxygen
      khelpcenter
      plasma-browser-integration
      print-manager
    ];
  };
}
