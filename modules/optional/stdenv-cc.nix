# description: Nix stdenv C/C++ runtime
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.stdenv.cc.cc ];
}
