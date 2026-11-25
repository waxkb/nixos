# description: Yazi terminal file manager
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.yazi ];
}
