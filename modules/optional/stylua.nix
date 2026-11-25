# description: StyLua Lua formatter
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.stylua ];
}
