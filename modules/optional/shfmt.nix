# description: shfmt shell formatter
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.shfmt ];
}
