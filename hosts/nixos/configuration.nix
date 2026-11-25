{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "bcachefs";
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime"
    ];
  };

  system.stateVersion = "25.11";

  # This box is NVIDIA-only: keep the iGPU off. Generic new hosts do
  # NOT set this; hybrid laptops need both GPUs.
  boot.kernelParams = [ "amdgpu.enable=0" ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];

  boot.initrd.includeDefaultModules = false;

  systemd.services.NetworkManager-wait-online.enable = false;

  networking.hostName = "nixos";
}
