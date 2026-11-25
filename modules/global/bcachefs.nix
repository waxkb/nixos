{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  boot.supportedFilesystems = [ "bcachefs" ];

  # The out-of-tree bcachefs module shipped with the default kernel in the
  # current nixpkgs (1.39.7 against Linux 6.18) does not compile against the
  # 6.18 inode API, while the same module builds against linuxPackages_latest.
  # Keep the default here so hosts that only need basic bcachefs support still
  # build; an explicit boot.kernelPackages in a host can override it.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
}
