# description: Google Chrome browser
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.google-chrome ];
}
