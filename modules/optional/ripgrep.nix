# description: ripgrep recursive search
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.ripgrep ];
}
