# description: Location services (geoclue2)
{
  lib,
  ...
}:
{
  services.geoclue2.enable = lib.mkDefault false;
}
