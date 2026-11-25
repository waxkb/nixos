# description: GNU Stow dotfile manager
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.stow ];
}
