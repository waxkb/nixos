# description: Python 3.14 interpreter
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.python314 ];
}
