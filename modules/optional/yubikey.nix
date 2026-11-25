# description: YubiKey and smartcard support
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.pcscd.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.systemPackages = with pkgs; [
    yubikey-manager
    libfido2
  ];
}
