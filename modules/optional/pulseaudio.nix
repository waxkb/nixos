# description: PulseAudio client tools
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.pulseaudio ];
}
