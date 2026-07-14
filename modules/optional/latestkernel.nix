{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
