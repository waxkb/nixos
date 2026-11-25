# description: fast CLI download speed tester
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.fast ];
}
