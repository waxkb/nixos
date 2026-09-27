{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  system = pkgs.system;
in
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

  # swapDevices = [
  #   {
  #     device = "/var/lib/swapfile";
  #     size = 16 * 1024; # 16 GiB
  #   }
  # ];

  # boot.zswap = {
  #   enable = true;
  #   compressor = "lz4";
  # };

  # programs.sss = {
  #   enable = true;
  #   code = true;
  # };

  programs.kdeconnect.enable = false;

  # This box is NVIDIA-only: keep the iGPU off. Generic new hosts do
  # NOT set this (see modules/hardware/gpu-nvidia.nix); hybrid laptops
  # need both GPUs.
  boot.kernelParams = [ "amdgpu.enable=0" ];

  # programs.obs-studio = {
  #   enable = true;
  #   package = (
  #     pkgs.obs-studio.override {
  #       cudaSupport = true;
  #     }
  #   );
  #   plugins = with pkgs.obs-studio-plugins; [
  #     obs-pipewire-audio-capture
  #   ];
  # };

  system.stateVersion = "25.11";

  services.power-profiles-daemon.enable = false;
  services.upower.enable = false;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];

  boot.initrd.includeDefaultModules = false;

  boot.initrd.systemd.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false; # Doesn't wait to connect to internet before booting

  networking.hostName = "nixos";

  nixpkgs.config = {
    allowUnfree = true;
    freetype = {
      hinting = true;
    };
  };

  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.blueman.enable = false;

  services.accounts-daemon.enable = false;
  services.geoclue2.enable = false;
}
