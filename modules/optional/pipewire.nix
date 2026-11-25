# description: PipeWire audio stack
{
  lib,
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
}
