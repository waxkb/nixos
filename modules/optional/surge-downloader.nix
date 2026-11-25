# description: Surge download manager
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.surge-downloader ];
}
