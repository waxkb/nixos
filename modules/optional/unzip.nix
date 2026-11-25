# description: unzip archive extractor
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.unzip ];
}
