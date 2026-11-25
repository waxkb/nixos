# description: GnuPG agent with SSH support
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
