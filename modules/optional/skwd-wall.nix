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
