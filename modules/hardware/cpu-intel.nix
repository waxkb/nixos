{ config, lib, ... }:
{
  # Intel CPUs: microcode updates + KVM.
  # Picked by the installer when /proc/cpuinfo reports GenuineIntel.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = [ "kvm-intel" ];

  # Thermald is Intel-only; harmless if the package is present but the
  # CPU is AMD, so keep it in the laptop module instead. See laptop.nix.
}
