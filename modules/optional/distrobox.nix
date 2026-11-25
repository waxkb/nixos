# description: distrobox container integration
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.distrobox ];
}
