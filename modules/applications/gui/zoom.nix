{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.zoom;
in
  with lib;
{
  options = {
    host.home.applications.zoom = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Video Conferencing";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          zoom-us
        ];
    };

    xdg.mimeApps = mkIf (config.host.home.feature.mime.defaults.enable) {
      defaultApplications = {
        "x-scheme-handler/zoomtg" = "us.zoom.Zoom.desktop";
      };
    };
  };
}
