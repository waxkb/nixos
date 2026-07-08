{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./bcachefs.nix
    ./boot.nix
    ./locale.nix
    ./network.nix
    ./opts.nix
    ./users.nix
  ];
}
