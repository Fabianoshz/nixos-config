{
  description = "NixOS configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
    # home-manager.url = "github:nix-community/home-manager/release-25.05";
      url = "github:pitkling/home-manager/575754a37c7f0a182b481957fdba940faedf96b5"; # For declarative syncthing for Mac too
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    xdg-autostart.url = "github:Zocker1999NET/home-manager-xdg-autostart";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    swww.url = "github:LGFae/swww";

    lightly.url = "github:Bali10050/Darkly";
  };

  outputs = {
    nixpkgs,
    nix-darwin,
    home-manager,
    jovian-nixos,
    plasma-manager,
    mac-app-util,
    xdg-autostart,
    nix-flatpak,
    spicetify-nix,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    system-mac = "aarch64-darwin";
  in
  {
    homeConfigurations = {
      "fabiano@GipsyDanger" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };

        extraSpecialArgs = { inherit nixpkgs plasma-manager system inputs; };
        modules = [
          ./home-manager/users/fabiano/GipsyDanger/home.nix

          inputs.xdg-autostart.homeManagerModules.xdg-autostart
	  inputs.spicetify-nix.homeManagerModules.default
        ];
      };

      "fabiano@GipsyAvenger" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };

        extraSpecialArgs = { inherit nixpkgs plasma-manager system; };
        modules = [
          ./home-manager/users/fabiano/GipsyAvenger/home.nix

          inputs.xdg-autostart.homeManagerModules.xdg-autostart
          nix-flatpak.homeManagerModules.nix-flatpak
        ];
      };

      "fabiano" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };

        extraSpecialArgs = { inherit nixpkgs system-mac; };
        modules = [
          ./home-manager/users/fabiano/CrimsonPhoenix/home.nix
        ];
      };
    };

    nixosConfigurations = {
      GipsyDanger = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          { nixpkgs.config.pkgs = nixpkgs; }

          ./nixos/hosts/GipsyDanger/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      GipsyAvenger = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          ./nixos/hosts/GipsyAvenger/configuration.nix

          nix-flatpak.nixosModules.nix-flatpak
          jovian-nixos.nixosModules.default
          home-manager.nixosModules.home-manager
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

          # home-manager.darwinModules.home-manager

          # mac-app-util.darwinModules.default
          # (
          #   { ... }:
          #   {
          #     home-manager.sharedModules = [
          #       mac-app-util.homeManagerModules.default
          #     ];
          #   }
          # )
        ];
      };
    };
  };
}
