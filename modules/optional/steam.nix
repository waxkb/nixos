{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.steam = {
    enable = true;
  };
  programs.gamemode.enable = true;
}
