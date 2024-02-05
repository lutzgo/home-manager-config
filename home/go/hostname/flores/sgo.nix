{ config, lib, pkgs, ...}:
{
  host = {
    home = {
      applications = {
        act.enable = false;
        android-tools.enable = true;
        calibre.enable = true;
        encfs.enable = false;
        git.enable = true;
        github-client.enable = false;
        hugo.enable = false;
        lazygit.enable = false;
        nextcloud-client.enable = true;
        tea.enable = false;
      };
      feature = {
        gui = {
          enable = true;
          displayServer = "wayland";
					windowManager = "hyprland";
        };
				fonts.enable = true;
				mime-defaults.enable = true;
        theming.enable = true;
      };
      service = {
        decrypt_encfs_workspace.enable = false;
        vscode-server.enable = false;
      };
    };
  };
}
