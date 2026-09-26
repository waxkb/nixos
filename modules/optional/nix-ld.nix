{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # FHS / binary compat for tools like opencode that exec prebuilt binaries.
  # Extracted from hosts/nixos/configuration.nix so new hosts get it
  # via a module instead of host-local config.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      libx11
      libxinerama
      libxext
      libGL
    ];
  };
}
