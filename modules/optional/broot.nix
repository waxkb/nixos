# description: broot directory tree navigator
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.broot ];
}
