# description: wev Wayland event viewer
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.wev ];
}
