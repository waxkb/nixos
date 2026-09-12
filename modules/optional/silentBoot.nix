{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=false"
  ];
}
