{
  description = "saldkjf";
  inputs = {

    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";

    # home-manager.url = "github:nix-community/home-manager";

    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-core.url = "github:manic-systems/nixos-core";

    ncro.url = "github:manic-systems/ncro";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      zen-browser,
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
            ./hosts/server
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
    };
}
