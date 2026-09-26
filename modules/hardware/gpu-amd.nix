{ pkgs, lib, ... }:
{
  # AMD iGPU / dGPU (amdgpu). Selected when lspci shows AMD VGA/3D.
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = false;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  hardware.amdgpu.opencl.enable = lib.mkDefault false;

  # Don't fight the NVIDIA module on hybrid machines: if gpu-nvidia.nix
  # is also included, both drivers are installed and X/Wayland picks
  # the right one. No `amdgpu.enable=0` here on purpose.
}
