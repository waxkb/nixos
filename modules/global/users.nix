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
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGh6KWt6dNi46lrhhzfS54012/UPitFzhRWlDDNqb+To maxwellr2028@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0rNyQbOAW6P+ZL/hsVIbR89QqNEf7Nj8BTmEXJ7jn/ nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKcsbASHuRQ8fO94Fh5xRYsesaSRfAYFAkTBQc/0pqOR waxkb-nixos"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGh6KWt6dNi46lrhhzfS54012/UPitFzhRWlDDNqb+To maxwellr2028@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0rNyQbOAW6P+ZL/hsVIbR89QqNEf7Nj8BTmEXJ7jn/ nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKcsbASHuRQ8fO94Fh5xRYsesaSRfAYFAkTBQc/0pqOR waxkb-nixos"
    ];
  };
}
