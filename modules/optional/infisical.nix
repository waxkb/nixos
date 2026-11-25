# description: Infisical secrets CLI
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.infisical ];
}
