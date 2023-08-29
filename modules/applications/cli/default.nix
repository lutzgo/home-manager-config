{lib, ...}:

with lib;
{
  imports = [
    ./act.nix
    ./bat.nix
    ./btop.nix
    ./fzf.nix
    ./gnupg.nix
    ./htop.nix
    ./jq.nix
    ./lazygit.nix
    ./less.nix
    ./liquidprompt.nix
    ./lsd.nix
    ./mp3gain.nix
    ./nano.nix
    ./neofetch.nix
    ./ncdu.nix
    ./nmap.nix
    ./tmux.nix
    ./yt-dlp.nix
    ./zoxide.nix
  ];
}