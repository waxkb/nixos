# description: hyprlock Wayland screen locker
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.hyprlock ];
}
