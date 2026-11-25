# description: lz4 compression tools
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.lz4 ];
}
