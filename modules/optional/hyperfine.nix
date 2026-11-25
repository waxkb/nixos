# description: hyperfine command benchmarker
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.hyperfine ];
}
