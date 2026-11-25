# description: matugen Material You color generator
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.matugen ];
}
