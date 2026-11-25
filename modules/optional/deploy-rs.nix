# description: deploy-rs remote deployment tool
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.deploy-rs ];
}
