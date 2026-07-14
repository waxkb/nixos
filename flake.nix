{
  description = "saldkjf";
  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-core.url = "github:manic-systems/nixos-core";

    ncro.url = "github:manic-systems/ncro";

    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    matugen = {
      url = "github:InioX/Matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuigreet = {
      url = "github:NotAShelf/tuigreet";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # claude-code.url = "github:sadjow/claude-code-nix";

    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sss.url = "github:SergioRibera/sss";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      # zen-browser,
      matugen,
      dms,
      noctalia,
      tuigreet,
      # claude-code,
      ncro,
      nixos-core,
      glide,
      # sss,
      hjem,
      deploy-rs,
      ...
    }:
    let

      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixos-core.nixosModules.default
            inputs.dms.nixosModules.dank-material-shell
            inputs.ncro.nixosModules.default
            ./hosts/nixos
            ./modules/global
            ./modules/optional/ccache.nix
            ./modules/optional/desktop.nix
            ./modules/optional/direnv.nix
            ./modules/optional/fonts.nix
            ./modules/optional/greetd.nix
            ./modules/optional/latestkernel.nix
            ./modules/optional/ncro.nix
            ./modules/optional/nh.nix
            ./modules/optional/nixos-core.nix
            ./modules/optional/nvidia.nix
            ./modules/optional/podman.nix
            ./modules/optional/steam.nix
            # sss.nixosModules.default
            {
              nixpkgs.overlays = [
                # (final: prev: {
                #   inherit (prev.lixPackageSets.stable)
                #     nixpkgs-review
                #     nix-eval-jobs
                #     nix-fast-build
                #     colmena
                #     ;
                # })
                noctalia.overlays.default
                # claude-code.overlays.default
              ];
            }
          ];

          specialArgs = {
            inherit inputs;
          };
        };
        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.hjem.nixosModules.default
            ./hosts/server
            ./modules/global
            ./modules/optional/hjem.nix
            ./modules/optional/latestkernel.nix
            ./modules/optional/podman.nix
            ./modules/optional/server-laptop.nix
            ./modules/optional/nh.nix
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
      deploy.nodes = {
        server = {
          hostname = "10.0.0.43";
          profiles.system = {
            sshUser = "root";
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.server;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
