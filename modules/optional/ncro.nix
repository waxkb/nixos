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
        # {
        #   url = "https://claude-code.cachix.org";
        #   priority = 5;
        #   public_key = "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=";
        # }
        {
          url = "https://noctalia.cachix.org";
          priority = 5;
          public_key = "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=";
        }
        # {
        #   url = "https://sss.cachix.org";
        #   priority = 5;
        #   public_key = "sss.cachix.org-1:YI2JMG95LEu62PC7VMz75N7bypEdUz9Z/Il1hkGH4AA=";
        # }
      ];
    };
  };

  nix.settings.substituters = [ "http://localhost:8081" ];
}
