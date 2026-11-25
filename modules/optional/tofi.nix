# description: tofi Wayland launcher
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.tofi ];
}
