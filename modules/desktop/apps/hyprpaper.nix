{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.hyprpaper;
in
  with lib;
{
  options = {
    host.home.applications.hyprpaper = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Wayland Wallpaper Manager";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          hyprpaper
        ];
    };

  };
}