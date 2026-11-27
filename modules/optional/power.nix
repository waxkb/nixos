# description: Power profiles daemon + upower
{
  lib,
  ...
}:
{
  services.power-profiles-daemon.enable = lib.mkDefault false;
  services.upower.enable = lib.mkDefault false;
}
