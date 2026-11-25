# description: nix-tree store browser
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.nix-tree ];
}
