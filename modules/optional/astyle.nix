# description: AStyle C/C++ formatter
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.astyle ];
}
