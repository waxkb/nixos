# description: microfetch system fetch
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.microfetch ];
}
