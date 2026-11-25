# description: pavucontrol PulseAudio/PipeWire mixer
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.pavucontrol ];
}
