# description: tree directory listing
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.tree ];
}
