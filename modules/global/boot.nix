{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  systemd.services.systemd-udev-settle.enable = false;
}
