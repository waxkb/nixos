# description: curl HTTP client
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.curl ];
}
