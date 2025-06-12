{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS/?ref=f31df4cb6b2eeef6cf0113edb687297be72a69df";
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

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    xdg-autostart.url = "github:Zocker1999NET/home-manager-xdg-autostart";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    lightly.url = "github:Bali10050/Darkly/?ref=v0.5.16";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    jovian-nixos,
    plasma-manager,
    mac-app-util,
    xdg-autostart,
    nix-flatpak,
    spicetify-nix,
    firefox-addons,
    nix-homebrew,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    system-mac = "aarch64-darwin";

    pkgs-unstable = import nixpkgs-unstable {
      system = system;
      config.allowUnfree = true;
    };

    pkgs-unstable-mac = import nixpkgs-unstable {
      system = system-mac;
      config.allowUnfree = true;
    };
  in
  {
    homeConfigurations = {
      "fabiano@GipsyDanger" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
        };

        extraSpecialArgs = { inherit nixpkgs plasma-manager system inputs firefox-addons pkgs-unstable; };
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

        extraSpecialArgs = { inherit nixpkgs plasma-manager system inputs firefox-addons; };
        modules = [
          ./home-manager/users/fabiano/GipsyAvenger/home.nix

          inputs.xdg-autostart.homeManagerModules.xdg-autostart
          nix-flatpak.homeManagerModules.nix-flatpak
        ];
      };

      "fabiano@CrimsonPhoenix" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };

        extraSpecialArgs = { inherit nixpkgs system-mac inputs firefox-addons; pkgs-unstable = pkgs-unstable-mac; };
        modules = [
          ./home-manager/users/fabiano/CrimsonPhoenix/home.nix

	  inputs.spicetify-nix.homeManagerModules.default
        ];
      };

      "fabiano@D5FXW3H24T" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };

        extraSpecialArgs = { inherit nixpkgs system-mac; };
        modules = [
          ./home-manager/users/fabiano/D5FXW3H24T/home.nix
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

          home-manager.darwinModules.home-manager

          mac-app-util.darwinModules.default
          (
            { ... }:
            {
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
          )
        ];
      };

      D5FXW3H24T = nix-darwin.lib.darwinSystem {
        modules = [
          ./nixos/hosts/D5FXW3H24T/configuration.nix

          home-manager.darwinModules.home-manager

          mac-app-util.darwinModules.default
          (
            { ... }:
            {
              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];
            }
          )

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
