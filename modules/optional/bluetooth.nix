# description: Bluetooth support (BlueZ + blueman)
{
  lib,
  ...
}:
{
  hardware.bluetooth = {
    enable = lib.mkDefault false;
    powerOnBoot = lib.mkDefault false;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
  services.blueman.enable = lib.mkDefault false;
}
