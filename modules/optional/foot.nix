# description: foot Wayland terminal
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.foot ];
}
