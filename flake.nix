{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lightly.url = "github:Bali10050/Darkly/?ref=v0.5.37";

    # Bleeding edge stuff

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager-master = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/development";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    xdg-autostart.url = "github:Zocker1999NET/home-manager-xdg-autostart";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-on-thor = {
      url = "github:Fabianoshz/nix-on-thor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , nix-darwin
    , nixpkgs-unstable
    , home-manager-master
    , jovian-nixos
    , mac-app-util
    , nix-homebrew
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      system-mac = "aarch64-darwin";

      patchHomeManager = hm: hostSystem: nixpkgs.legacyPackages.${hostSystem}.callPackage ./pkgs/home-manager { src = hm; };
    in
    {
      nixosConfigurations = {
        GipsyDanger = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };

          modules = [
            { nixpkgs.hostPlatform = system; }
            ./nixos/hosts/GipsyDanger/configuration.nix

            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }

            "${patchHomeManager home-manager system}/nixos"
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/GipsyDanger/home.nix;
            }
          ];
        };

        GipsyAvenger = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit inputs; };

          modules = [
            { nixpkgs.hostPlatform = system; }
            ./nixos/hosts/GipsyAvenger/configuration.nix

            jovian-nixos.nixosModules.default
            "${patchHomeManager home-manager-master system}/nixos"
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/GipsyAvenger/home.nix;
            }
          ];
        };

        Thor = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };

          modules = [
            { nixpkgs.hostPlatform = "aarch64-linux"; }
            ./nixos/hosts/Thor/configuration.nix

            inputs.nix-on-thor.nixosModules.thor
            "${patchHomeManager home-manager "aarch64-linux"}/nixos"
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/Thor/home.nix;
            }
          ];
        };
      };

      darwinConfigurations = {
        CrimsonPhoenix = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/hosts/CrimsonPhoenix/configuration.nix

            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }

            "${patchHomeManager home-manager system-mac}/nix-darwin"
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/CrimsonPhoenix/home.nix;
            }

            mac-app-util.darwinModules.default

            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = "fabiano";
                autoMigrate = true;
              };
            }
          ];
        };

        D5FXW3H24T = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/hosts/D5FXW3H24T/configuration.nix

            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    system = prev.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }

            "${patchHomeManager home-manager system-mac}/nix-darwin"
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/D5FXW3H24T/home.nix;
            }

            mac-app-util.darwinModules.default

            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = "fabiano";
              };
            }
          ];
        };
      };
    };
}
