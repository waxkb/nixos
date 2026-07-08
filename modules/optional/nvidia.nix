{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    "amdgpu.enable=0"
    "8250.nr_uarts=0"
    "quiet"
    "loglevel=3"
    "systemd.show_status=auto"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=false"
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    BLINK_CMP_DIR = "${pkgs.vimPlugins.blink-cmp}";
    FRIENDLY_SNIPPETS_DIR = "${pkgs.vimPlugins.friendly-snippets}";
    GTK_THEME = "Adwaita:dark";
    GTK_COLOR_SCHEME = "prefer-dark";
  };

  systemd.services."getty@tty1".enable = false;
}
