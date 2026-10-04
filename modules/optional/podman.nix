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
      registries.search = [
        "docker.io"
        "quay.io"
      ];
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
