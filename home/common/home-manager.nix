{ config, lib, pkgs, ... }:
with lib;
{
  home = {
    stateVersion = mkDefault "23.11";
  };

  manual.manpages.enable = mkDefault false;
  news.display = "show";

  programs = {
    home-manager = {
      enable = mkForce true;
    };
  };
}
