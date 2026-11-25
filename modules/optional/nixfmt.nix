# description: nixfmt-rs Nix formatter
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.nixfmt-rs ];
}
