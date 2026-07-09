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
      AllowUsers = [ "max" "root" ];
      MaxAuthTries = 5;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };
}
