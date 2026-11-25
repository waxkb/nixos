# description: hyprpicker Wayland color picker
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.hyprpicker ];
}
