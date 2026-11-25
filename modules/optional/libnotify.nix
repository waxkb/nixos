# description: libnotify desktop notifications
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.libnotify ];
}
