# description: starship shell prompt
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.starship ];
}
