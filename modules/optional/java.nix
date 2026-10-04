{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };
}
