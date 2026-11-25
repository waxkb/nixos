# description: Podman containers with Docker compatibility
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  virtualisation = {
    containers = {
      enable = true;
      registries.settings = {
        "unqualified-search-registries" = [
          "docker.io"
          "quay.io"
        ];
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.max.extraGroups = [ "podman" ];
}
