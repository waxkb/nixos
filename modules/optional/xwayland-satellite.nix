# description: Xwayland satellite for wlroots compositors
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
