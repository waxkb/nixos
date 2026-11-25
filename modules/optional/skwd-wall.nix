# description: skwd-wall wallpaper service
# requires: desktop
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.skwd-wall.nixosModules.default
  ];

  services.skwd-deck = {
    enable = true;
  };
}
