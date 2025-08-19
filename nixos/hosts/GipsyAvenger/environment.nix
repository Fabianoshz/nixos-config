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
  };
}
