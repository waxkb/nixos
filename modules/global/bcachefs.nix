{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot.supportedFilesystems = [ "bcachefs" ];
}
