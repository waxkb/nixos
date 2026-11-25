# description: GCC compiler
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.gcc ];
}
