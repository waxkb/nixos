{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  services.ncro = {
    enable = true;
    settings = {
      server = {
        listen = ":8081";
      };
      upstreams = [
        {
          url = "https://cache.nixos.org";
          priority = 10;
          public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        }
        {
          url = "https://nix-community.cachix.org";
          priority = 20;
          public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        }
        {
          url = "https://noctalia.cachix.org";
          priority = 5;
          public_key = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
        }
      ];
    };
  };

  nix.settings.substituters = [ "http://localhost:8081" ];
}
