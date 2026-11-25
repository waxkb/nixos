# description: manic-systems nixos-core module
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nixos-core.nixosModules.default ];

  system.nixos-core.enable = true;
}
