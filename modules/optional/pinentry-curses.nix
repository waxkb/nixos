# description: pinentry-curses GPG pinentry
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.pinentry-curses ];
}
