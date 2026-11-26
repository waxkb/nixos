{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
      AllowUsers = [
        "max"
        "root"
      ];
      MaxAuthTries = 5;
      # Trusted Tailscale mesh is exempt from penalties; anything else gets
      # short, sane bans instead of an hour-long ban from one hiccup.
      PerSourcePenaltyExemptList = "100.64.0.0/10";
      PerSourcePenalties = "crash:60s authfail:60s max:600s";
    };
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
