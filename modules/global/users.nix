{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  users.users.max = {
    isNormalUser = true;
    description = "max";

    extraGroups = [
      "wheel"
      "networkmanager"
      "podman"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGh6KWt6dNi46lrhhzfS54012/UPitFzhRWlDDNqb+To maxwellr2028@gmail.com"
    ];
  };
}
