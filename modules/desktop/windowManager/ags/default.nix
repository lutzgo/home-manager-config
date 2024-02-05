{ config, inputs, lib, pkgs, ...}:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
in
with lib;
{
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    programs.ags = {
      enable = true;
    };

    configDir = ../ags;

    home = {
      packages = with pkgs;
        [
          gtksourceview
          webkitgtk
          accountsservice
        ];
    };
  };
}
