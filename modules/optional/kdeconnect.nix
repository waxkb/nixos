# description: KDE Connect phone-desktop integration
{
  lib,
  ...
}:
{
  programs.kdeconnect.enable = lib.mkDefault false;
}
