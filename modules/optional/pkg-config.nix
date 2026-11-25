# description: pkg-config development helper
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.pkg-config ];
}
