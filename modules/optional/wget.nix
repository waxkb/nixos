# description: wget downloader
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.wget ];
}
