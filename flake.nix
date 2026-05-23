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
          homeConfigurations =
            let
              hm = inputs.home-manager.lib.homeManagerConfiguration;
            in
            {
              # Personal
              zohar = hm {
                system = "x86_64-linux";
                username = "zohar";
                homeDirectory = "/var/home/zohar";

                modules = [ ./profiles/personal.nix ];
              };

              # Unmanaged Linux
              "zohar@ZOM-EquinorUMPC" = {
                system = "x86_64-linux";
                username = "zohar";
                homeDirectory = "/var/home/zohar";

                modules = [ ./profiles/work-unmanaged-linux.nix ];
              };

              # Managed Linux
              zom = hm {
                system = "x86_64-linux";
                username = "zom";
                homeDirectory = "/private/zom";

                modules = [ ./profiles/work-managed-linux.nix ];
              };

              # Managed macOS
              ZOM = hm {
                system = "aarch64-darwin";
                username = "ZOM";
                homeDirectory = "/Users/ZOM";

                modules = [ ./profiles/work-managed-macos.nix ];
              };
            };

          homeModules = {
            nix-index = inputs.nix-index-database.homeModules.nix-index;
            lazyvim = inputs.lazyvim-nix.homeManagerModules.lazyvim;

            defaults = {
              nixpkgs.config.allowUnfree = true;

              # https://github.com/NixOS/nixpkgs/issues/507531#issuecomment-4391486390
              nixpkgs.overlays = [
                (
                  _final: prev:
                  if prev.stdenv.hostPlatform.isDarwin then
                    {
                      inherit (inputs.nixpkgs-darwin-fish-fix.legacyPackages.${prev.stdenv.hostPlatform.system}) fish;
                    }
                  else
                    { }
                )
              ];

              home = {
                stateVersion = "25.11";
              };
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
