# description: iwd wireless daemon
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.iwd ];
}
