# description: jq JSON processor
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.jq ];
}
