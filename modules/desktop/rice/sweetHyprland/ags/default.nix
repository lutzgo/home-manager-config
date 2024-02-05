{ config, inputs, lib, pkgs, ...}:
{
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = {
    enable = true;
  };

  #configDir = ../ags;

  home = {
    packages = with pkgs; [
      gtksourceview
      webkitgtk
			accountsservice
		];
	};
}