{
  description = "NixOS configuration";

  inputs = {
    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-23-11.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-mac-dbeaver.url = "github:nixos/nixpkgs/224aa24a1c6ce18991dec003b29d1fbe04f8eb3e";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    vscode-runner = {
      url = "github:Merrit/vscode-runner";
      flake = false;
    };
  };
  outputs = inputs@{ nixpkgs, nixpkgs-23-11, home-manager, plasma-manager, jovian-nixos, ... }:
  let
    system = "x86_64-linux";
    pkgs-23-11 = import nixpkgs-23-11 {inherit system;};
    pkgs-unstable = import nixpkgs-unstable { inherit system;  };
  in
  {
    homeConfigurations = {
      "fabiano@GipsyDanger" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };

        extraSpecialArgs = { inherit nixpkgs pkgs-23-11 plasma-manager system inputs; };
        modules = [
          ./modules/home-manager/users/fabiano/home.nix

          ./modules/home-manager/core/kde/default.nix
          ./modules/home-manager/core/zsh/default.nix
          ./modules/home-manager/optional/git/default.nix
          ./modules/home-manager/optional/neovim/default.nix
          ./modules/home-manager/optional/vscode/default.nix
        ];
      };

      "fabiano@GipsyAvenger" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
        };

        extraSpecialArgs = { inherit nixpkgs pkgs-unstable pkgs-23-11 plasma-manager system; };
        modules = [
          ./modules/home-manager/users/fabiano/home.nix

          ./modules/home-manager/core/kde/default.nix
          ./modules/home-manager/core/zsh/default.nix
          ./modules/home-manager/optional/neovim/default.nix
        ];
      };

      "fabiano@CrimsonPhoenix" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };

        # extraSpecialArgs = { inherit nixpkgs pkgs-23-11 plasma-manager system inputs; };
        modules = [
          ./modules/home-manager/users/fabiano/CrimsonPhoenix/home.nix
        ];
      };
    };

    nixosConfigurations = {
      GipsyDanger = nixpkgs.lib.nixosSystem {
        system = "x86-64_linux";

        modules = [
          ./modules/nixos/GipsyDanger/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      GipsyAvenger = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.pkgs = pkgs-unstable; }

          ./modules/nixos/GipsyAvenger/configuration.nix
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
        system = "aarch64-darwin";

        modules = [
          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
