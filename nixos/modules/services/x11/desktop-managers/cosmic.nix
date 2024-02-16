{ config, pkgs, lib, ... }:

let
  cfg = config.services.xserver.desktopManager.cosmic;
in
{
  meta.maintainers = with lib.maintainers; [ nyanbinary ];

  options.services.xserver.desktopManager.cosmic = {
    enable = lib.mkEnableOption (lib.mdDoc "COSMIC desktop environment");
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [ "/share/cosmic" ];

    environment.systemPackages = with pkgs; [
      cosmic-applibrary
      cosmic-applets
      cosmic-bg
      cosmic-comp
      cosmic-edit
      cosmic-files
      cosmic-greeter
      cosmic-icons
      cosmic-launcher
      cosmic-notifications
      cosmic-osd
      cosmic-panel
      cosmic-randr
      cosmic-screenshot
      cosmic-settings
      cosmic-term
      cosmic-workspaces-epoch
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-cosmic
        xdg-desktop-portal-gtk
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-cosmic
      ];
    };

    hardware.opengl.enable = true;
    services.xserver.libinput.enable = true;

    security.polkit.enable = true;

    services.xserver.displayManager.sessionPackages = with pkgs; [ cosmic-session ];
    systemd.packages = with pkgs; [ cosmic-session ];

    services.xserver.displayManager.cosmic-greeter.enable = lib.mkDefault true;
  };
}
