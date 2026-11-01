{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.udev.packages = [ pkgs.yubikey-personalization ];
}
