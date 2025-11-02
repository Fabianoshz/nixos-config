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
      url = "github:Jovian-Experiments/Jovian-NixOS/?ref=533db5857c9e00ca352558a928417116ee08a824";
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
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/GipsyDanger/home.nix;
            }
          ];
        };

        GipsyAvenger = nixpkgs-unstable.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs; };

          modules = [
            ./nixos/hosts/GipsyAvenger/configuration.nix

            jovian-nixos.nixosModules.default
            home-manager-master.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.fabiano = import ./home-manager/users/fabiano/GipsyAvenger/home.nix;
            }
          ];
        };
      };

      darwinConfigurations = {
        CrimsonPhoenix = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/hosts/CrimsonPhoenix/configuration.nix

            home-manager.darwinModules.home-manager
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

            home-manager.darwinModules.home-manager
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
