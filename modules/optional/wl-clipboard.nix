# description: wl-clipboard Wayland clipboard tools
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
