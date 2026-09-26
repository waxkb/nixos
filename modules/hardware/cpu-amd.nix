{ config, lib, ... }:
{
  # AMD CPUs: microcode updates + KVM.
  # Picked by the installer when /proc/cpuinfo reports AuthenticAMD.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.kernelModules = [ "kvm-amd" ];
}
