{
  description = "NixOS configuration";

  inputs = {
    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-23-11.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-input-plumber.url = "github:nixos/nixpkgs/a198f344f6982843ba84316183bce215a21e0f23";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.url = "github:karaolidis/home-manager/c95de330277971e3954361199e049b0e38e8d441";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    nixpkgs-23-11,
    nixpkgs-input-plumber,
    nixpkgs-unstable,
    nixpkgs,
    home-manager-unstable,
    home-manager,
    jovian-nixos,
    nix-darwin,
    plasma-manager,
    ...
  }@inputs:
  let
    lib = nixpkgs-unstable.lib;
  in
  let
    system = "x86_64-linux";
    system-mac = "aarch64-darwin";

    pkgs-23-11 = import nixpkgs-23-11 {inherit system;};
    pkgs-unstable = import nixpkgs-unstable { inherit system;  };
    pkgs-input-plumber = import nixpkgs-input-plumber { inherit system;  };

    # home-manager-unstable = {
    #   overlays = [
    #     (final: prev: {
    #       inherit (import home-manager-unstable {system = "x86_64-linux"; })
    #         syncthing;
    #     })
    #   ]
    # }

    nixosModules = (import ./modules/nixos/modules { inherit lib; });
  in
  {
    homeConfigurations = {
      "fabiano@GipsyDanger" = home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-unstable {
          system = "x86_64-linux";
        };

        extraSpecialArgs = { inherit nixpkgs pkgs-23-11 plasma-manager system inputs; };
        modules = [
          ./modules/home-manager/users/fabiano/GipsyDanger/home.nix

          ./modules/home-manager/core/kde/default.nix
          ./modules/home-manager/core/zsh/default.nix
          ./modules/home-manager/optional/git/default.nix
          ./modules/home-manager/optional/neovim/default.nix
          ./modules/home-manager/optional/vscode/default.nix
        ];
      };

      "fabiano@GipsyAvenger" = home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-unstable {
          system = "x86_64-linux";
        };

        extraSpecialArgs = { inherit nixpkgs pkgs-23-11 plasma-manager system; };
        modules = [
          ./modules/home-manager/users/fabiano/GipsyAvenger/home.nix

          ./modules/home-manager/core/kde/default.nix
          ./modules/home-manager/core/zsh/default.nix
          ./modules/home-manager/optional/neovim/default.nix

          ./modules/home-manager/modules/pcsx2-qt-exec/default.nix
        ];
      };

      "fabiano@CrimsonPhoenix" = home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-unstable {
          system = "aarch64-darwin";
        };

        extraSpecialArgs = { inherit nixpkgs-unstable pkgs-unstable system-mac; };
        modules = [
          ./modules/home-manager/users/fabiano/CrimsonPhoenix/home.nix

          ./modules/home-manager/core/zsh/default.nix
          ./modules/home-manager/optional/git/default.nix
          ./modules/home-manager/optional/neovim/default.nix
          ./modules/home-manager/optional/vscode/default.nix
        ];
      };
    };

    nixosConfigurations = {
      GipsyDanger = nixpkgs-unstable.lib.nixosSystem {
        system = "x86-64_linux";

        modules = [
          { nixpkgs.config.pkgs = pkgs-unstable; }

          ./modules/nixos/hosts/GipsyDanger/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };

      GipsyAvenger = nixpkgs-unstable.lib.nixosSystem {
        system = "x86-64_linux";

        specialArgs = {
          inherit pkgs-input-plumber;
        };

        modules = [
          { nixpkgs.config.pkgs = pkgs-unstable; }

          ./modules/nixos/hosts/GipsyAvenger/configuration.nix

          ./modules/nixos/modules/decky-loader.nix

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
        system = system-mac;

        modules = [
          ./modules/nixos/hosts/CrimsonPhoenix/configuration.nix

          home-manager.darwinModules.home-manager
        ];
      };
    };
  };
}
