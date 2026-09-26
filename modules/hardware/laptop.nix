{ config, lib, pkgs, ... }:
{
  # Laptop profile. Included by the installer only when the user says
  # the machine is a laptop. Deliberately does NOT disable sleep /
  # hibernate or ignore the lid switch (unlike server-laptop.nix,
  # which is for running a laptop as a headless server).
  #
  # Swap itself lives in hardware-configuration.nix / host
  # configuration.nix as a real partition (RAM size, capped at 16G);
  # this module only adds the in-RAM compression + power stack.

  boot.zswap = {
    enable = true;
    compressor = "lz4";
  };

  services.power-profiles-daemon.enable = lib.mkForce true;
  services.upower.enable = lib.mkForce true;
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  services.thermald.enable = lib.mkDefault true;
  services.tlp.enable = lib.mkForce false; # conflicts with PPD

  # Laptops move around: bluetooth + location + wifi regulatory help.
  hardware.bluetooth = {
    enable = lib.mkForce true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = lib.mkForce true;
  services.geoclue2.enable = lib.mkForce true;
  hardware.wirelessRegulatoryDatabase = true;
  networking.networkmanager.wifi.backend = lib.mkDefault "iwd";

  # Battery / lid / sleep defaults: use upstream NixOS behavior
  # (suspend on lid close) — nothing to set here on purpose.
}
