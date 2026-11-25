# description: yt-dlp media downloader
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.yt-dlp ];
}
