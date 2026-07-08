{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh = {
    enable = true;
  };

  documentation.enable = false;
  documentation.man.enable = false;

  services.desktopManager.gnome.enable = false;

  services.envfs.enable = true;
}
