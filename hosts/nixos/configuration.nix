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

  # nix.package = pkgs.lixPackageSets.git.lix;

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

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    libx11
    libxinerama
    libxext
    libGL
  ];

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

  programs.java.enable = true;

  system.stateVersion = "25.11";

  boot.loader.limine = {
    enable = false;
    maxGenerations = null;
    extraConfig = ''
      quiet: yes
    '';
  };

  services.power-profiles-daemon.enable = false;
  services.upower.enable = false;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
  ];

  boot.initrd.includeDefaultModules = false;

  boot.consoleLogLevel = 0;

  systemd.services.systemd-journal-flush.enable = false;

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
}
