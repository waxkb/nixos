{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };
}
