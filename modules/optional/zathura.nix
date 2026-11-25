# description: Zathura document viewer
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.zathura ];
}
