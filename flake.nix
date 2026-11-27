{
  description = "waxkb NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umbriel.url = "github:noctalia-dev/umbriel/cachix";

    spotatui = {
      url = "github:LargeModGames/spotatui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ncro = {
      url = "github:manic-systems/ncro";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-core = {
      url = "github:manic-systems/nixos-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    skwd-wall = {
      url = "github:liixini/skwd-wall/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yami = {
      url = "github.com:Trendorin/yami";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      deploy-rs,
      ...
    }:
    let
      lib = nixpkgs.lib;

      hostNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      mkHost =
        name:
        let
          meta = import (./hosts + "/${name}/meta.nix");
        in
        {
          inherit meta;
          config = lib.nixosSystem {
            system = meta.system;
            modules = [
              (./hosts + "/${name}")
              ./modules/global
            ];
            specialArgs = { inherit inputs; };
          };
        };

      hosts = lib.genAttrs hostNames mkHost;

      deployedHosts = lib.filterAttrs (_: host: host.meta.deploy.enable or false) hosts;
    in
    {
      nixosConfigurations = lib.mapAttrs (_: host: host.config) hosts;

      deploy.nodes = lib.mapAttrs' (
        name: host:
        lib.nameValuePair name {
          hostname = host.meta.deploy.hostname;
          profiles.system = {
            sshUser = host.meta.deploy.sshUser;
            user = "root";
            path = deploy-rs.lib.${host.meta.system}.activate.nixos host.config;
          };
        }
      ) deployedHosts;

      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
