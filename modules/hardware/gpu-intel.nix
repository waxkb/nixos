{ pkgs, ... }:
{
  # Intel iGPU / Arc (i915/xe are in-tree, no videoDrivers override needed
  # beyond modesetting). Selected when lspci shows Intel graphics.
  services.xserver.videoDrivers = [
    "modesetting"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = false;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
}
