{ config, lib, pkgs, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "gnome") {
    home = {
      packages = with pkgs;
        [
          glib
          gsettings-desktop-schemas
          killall
          libgnomekbd
          networkmanagerapplet
          polkit_gnome
          sound-theme-freedesktop
          xdg-user-dirs
          xplayer
        ];
    };

    services.xserver.desktopManager.gnome.enable = true;

    xsession = {
      enable = true;
      scriptPath = ".hm-xsession";
      windowManager.command = ''
        gnome-session
      '';
    };
  };
}
