# description: bat, a cat clone with syntax highlighting
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.bat ];
}
