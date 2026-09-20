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
    package = pkgs.openjdk25;
  };
}
