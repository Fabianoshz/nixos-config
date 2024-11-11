{
  description = "NixOS configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager.url = "github:nix-community/home-manager/release-24.11";
    # home-manager.url = "github:karaolidis/home-manager/c95de330277971e3954361199e049b0e38e8d441"; # For declarative syncthing
    home-manager.url = "github:pitkling/home-manager/7f98535dca2cc29f92ec1ce705eaf030f09975d3"; # For declarative syncthing for Mac too
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    mac-app-util.url = "github:hraban/mac-app-util";

    xdg-autostart.url = "github:Zocker1999NET/home-manager-xdg-autostart";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
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

        extraSpecialArgs = { inherit nixpkgs plasma-manager system; };
        modules = [
          ./modules/home-manager/users/fabiano/GipsyDanger/home.nix

          inputs.xdg-autostart.homeManagerModules.xdg-autostart
        ];
      };

      "fabiano@GipsyAvenger" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };

        extraSpecialArgs = { inherit nixpkgs plasma-manager system; };
        modules = [
          ./modules/home-manager/users/fabiano/GipsyAvenger/home.nix

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
          ./modules/home-manager/users/fabiano/CrimsonPhoenix/home.nix
        ];
      };
    };

    nixosConfigurations = {
      GipsyDanger = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          { nixpkgs.config.pkgs = nixpkgs; }

          ./modules/nixos/hosts/GipsyDanger/configuration.nix

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
          ./modules/nixos/hosts/GipsyAvenger/configuration.nix

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
          ./modules/nixos/hosts/CrimsonPhoenix/configuration.nix

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
