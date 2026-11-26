# description: Userspace console (kmscon) on tty1, replacing getty/Linux VTs
# note: owns tty1, so it must not be combined with a display manager (greetd)
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Keep all console/login settings in this module. The XKB options here are
  # only read by kmscon via useXkbConfig; they do not enable X11.
  services.xserver.xkb.layout = lib.mkDefault "us";

  # kmscon replaces autovt@/getty@ on every VT, including tty1. A display
  # manager would grab tty1 and suppress kmscon's static pull-in there.
  services.displayManager.enable = false;
  systemd.defaultUnit = "multi-user.target";

  services.kmscon = {
    enable = true;
    useXkbConfig = true;
    config = {
      hwaccel = true;
      libseat = true;
      font-name = "Maple Mono NF";

      # Chromebook has no PageUp/PageDown keys. kmscon ignores two-finger
      # scrolling (it only understands real wheel events), so use Search+Up /
      # Search+Down for page scrolling. Shift+Up / Shift+Down (default) still
      # scroll one line at a time.
      "grab-page-up" = "<Logo>Up";
      "grab-page-down" = "<Logo>Down";
    };
  };
}
