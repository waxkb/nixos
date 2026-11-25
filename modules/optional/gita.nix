# description: gita Git command manager
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.gita ];
}
