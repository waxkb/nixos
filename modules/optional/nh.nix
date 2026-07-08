{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/max/nixos"; # sets NH_OS_FLAKE variable
  };
}
