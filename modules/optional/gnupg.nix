{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
