{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    lightly.url = "github:Bali10050/Darkly/?ref=v0.5.16";

    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur?ref=v1.3.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Bleeding edge stuff

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager-master = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/?ref=fc3960e6c32c9d4f95fff2ef84444284d24d3bea";
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
  };

  outputs =
    { nixpkgs
    , home-manager
    , nix-darwin
    , nix-flatpak
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
    in
    {
      homeConfigurations = {
        "fabiano@GipsyDanger" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = system;
          };

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/users/fabiano/GipsyDanger/home.nix

            inputs.xdg-autostart.homeManagerModules.xdg-autostart
          ];
        };

        "fabiano@GipsyAvenger" = home-manager-master.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-unstable {
            system = system;
          };

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/users/fabiano/GipsyAvenger/home.nix

            nix-flatpak.homeManagerModules.nix-flatpak
            inputs.xdg-autostart.homeManagerModules.xdg-autostart
          ];
        };

        "fabiano@CrimsonPhoenix" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = system-mac;
          };

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/users/fabiano/CrimsonPhoenix/home.nix
            mac-app-util.homeManagerModules.default
          ];
        };

        "fabiano@D5FXW3H24T" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = system-mac;
          };

          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home-manager/users/fabiano/D5FXW3H24T/home.nix
            mac-app-util.homeManagerModules.default
          ];
        };
      };

      nixosConfigurations = {
        GipsyDanger = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };

          modules = [
            ./nixos/hosts/GipsyDanger/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

        GipsyAvenger = nixpkgs-unstable.lib.nixosSystem {
          system = system;

          modules = [
            ./nixos/hosts/GipsyAvenger/configuration.nix

            jovian-nixos.nixosModules.default
            home-manager-master.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
      };

      darwinConfigurations = {
        CrimsonPhoenix = nix-darwin.lib.darwinSystem {
          modules = [
            ./nixos/hosts/CrimsonPhoenix/configuration.nix

            home-manager.darwinModules.home-manager

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
          modules = [
            ./nixos/hosts/D5FXW3H24T/configuration.nix

            home-manager.darwinModules.home-manager

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
