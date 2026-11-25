# description: Android platform tools (adb, fastboot)
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.android-tools ];

  users.groups.adbusers = { };
  users.users.max.extraGroups = [ "adbusers" ];
}
