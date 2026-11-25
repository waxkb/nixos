# description: Git version control
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.git ];
}
