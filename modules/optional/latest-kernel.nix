# description: Latest mainline Linux kernel
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
