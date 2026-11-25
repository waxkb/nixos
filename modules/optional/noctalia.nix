# description: Noctalia Wayland desktop shell
# requires: desktop
{
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.noctalia.overlays.default ];

  environment.systemPackages = [ pkgs.noctalia ];
}
