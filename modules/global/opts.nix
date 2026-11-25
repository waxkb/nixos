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

  documentation.enable = false;
  documentation.man.enable = false;

  services.desktopManager.gnome.enable = false;
}
