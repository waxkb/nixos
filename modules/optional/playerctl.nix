# description: playerctl media player controller
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.playerctl ];
}
