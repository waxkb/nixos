# description: Tailscale mesh VPN
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.tailscale = {
    enable = true;

    # If you would like to use a preauthorized key, set
    # authKeyFile = "/run/secrets/tailscale_key";
    # Note: maximum expire time is 90 days
  };
}
