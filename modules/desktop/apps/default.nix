{lib, ...}:

with lib;
{
  imports = [
    ./autorandr.nix
    ./autokey.nix
    ./redshift.nix
    ./sysstat.nix
    ./wev.nix
    ./xbindkeys.nix
    ./xdotool.nix
    ./xbacklight.nix
    ./xdpyinfo.nix
    ./xev.nix
    ./xprop.nix
  ];
}
