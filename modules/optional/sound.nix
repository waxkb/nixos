# description: Sound stack (PipeWire, RTKit, ALSA/Pulse compatibility, client tools)
{
  lib,
  pkgs,
  ...
}:
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = lib.mkDefault false;
    wireplumber.enable = true;
  };

  environment.systemPackages = [
    pkgs.pavucontrol
    pkgs.pulseaudio
  ];
}
