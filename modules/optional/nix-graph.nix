# description: nix-graph dependency grapher
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.nix-graph ];
}
