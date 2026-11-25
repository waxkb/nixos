# description: activate-linux overlay
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.activate-linux ];
}
