{
  description = "Home Manager configuration of zohar";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://pinkwah.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pinkwah.cachix.org-1:ixwSFCqREV6E/3CAf4gjyd75PZQkRizMKzlkmlrdsx4="
    ];
  };

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # https://github.com/NixOS/nixpkgs/issues/507531#issuecomment-4391486390
    nixpkgs-darwin-fish-fix.url = "github:nixos/nixpkgs/9b8e6819224551756919099c1fce6e347f5a3803";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim-nix.url = "github:pfassina/lazyvim-nix";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    intellimacs = {
      url = "github:marcoieni/intellimacs";
      flake = false;
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        imports = [
          inputs.home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule
        ];

        flake = {
          homeConfigurations = {
            # Personal
            zohar = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
              modules = [
                inputs.self.homeModules.default
                ./profiles/personal.nix
                {
                  home = {
                    username = "zohar";
                    homeDirectory = "/var/home/zohar";
                  };
                }
              ];
              extraSpecialArgs = { inherit inputs; };
            };

            # Unmanaged Linux
            "zohar@ZOM-EquinorUMPC" = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
              modules = [
                ./profiles/work-unmanaged-linux.nix
                {
                  home = {
                    username = "zohar";
                    homeDirectory = "/var/home/zohar";
                  };
                }
              ];
            };

            # Managed Linux
            zom = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
              modules = [
                ./profiles/work-managed-linux.nix
                {
                  home = {
                    username = "zom";
                    homeDirectory = "/private/zom";
                  };
                }
              ];
            };

            # Managed macOS
            ZOM = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = import inputs.nixpkgs {
                system = "aarch64-darwin";

                # https://github.com/NixOS/nixpkgs/issues/507531#issuecomment-4391486390
                overlays = [
                  (_final: prev: {
                    inherit (inputs.nixpkgs-darwin-fish-fix.legacyPackages.${prev.stdenv.hostPlatform.system}) fish;
                  })
                ];
              };
              modules = [
                inputs.self.homeModules.default
                ./modules/default.nix
                ./profiles/work-managed-macos.nix
                {
                  home = {
                    username = "ZOM";
                    homeDirectory = "/Users/ZOM";
                  };
                }
              ];
              extraSpecialArgs = { inherit inputs; };
            };
          };

          homeModules = {
            default = {
              imports = [
                inputs.nix-index-database.homeModules.nix-index
                inputs.lazyvim-nix.homeManagerModules.lazyvim
                inputs.nix-doom-emacs-unstraightened.homeModule
                ./modules/opengl-driver
              ];

              nixpkgs.config.allowUnfree = true;

              home = {
                stateVersion = "25.11";
              };

              opengl-driver.enable = true;
            };
          };
        };

        perSystem =
          { config, pkgs, ... }:
          {
            treefmt = {
              programs.nixfmt.enable = true;
            };
          };
      }
    );
}
