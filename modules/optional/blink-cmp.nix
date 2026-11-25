# description: blink.cmp Neovim completion plugin
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.vimPlugins.blink-cmp ];
}
