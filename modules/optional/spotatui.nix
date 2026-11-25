{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    inputs.spotatui.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
