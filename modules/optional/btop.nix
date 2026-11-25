# description: btop system monitor
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.btop ];
}
