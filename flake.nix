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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    doom-emacs.url = "github:pinkwah/my-doom-config";
    intellimacs = {
      url = "github:marcoieni/intellimacs";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;

      profiles = rec {
        personal = {
          system = "x86_64-linux";
          username = "zohar";
          homeDirectory = "/var/home/zohar";
          modules = [ ./profiles/personal.nix ];
        };

        work-unmanaged-linux = personal // {
          modules = [ ./profiles/work-unmanaged-linux.nix ];
        };

        work-managed-linux = {
          system = "x86_64-linux";
          username = "zom";
          homeDirectory = "/private/zom";
          modules = [ ./profiles/work-managed-linux.nix ];
        };

        work-managed-macos = {
          system = "aarch64-darwin";
          username = "ZOM";
          homeDirectory = "/Users/ZOM";
          # modules = [ inputs.mac-app-util.homeManagerModules.default ./profiles/work-managed-macos.nix ];
          modules = [ ./profiles/work-managed-macos.nix ];
        };
      };

      configs = with profiles; {
        zohar = personal;
        "zohar@ZOM-EquinorUMPC" = work-unmanaged-linux;
        ZOM = work-managed-macos;
        zom = work-managed-linux;
      };

      mkHome = { system, username, homeDirectory, modules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = modules ++ [
            inputs.nix-index-database.homeModules.nix-index
            inputs.lazyvim-nix.homeManagerModules.lazyvim
            ./home.nix
            { home = { inherit username homeDirectory; }; }
          ];
          extraSpecialArgs = { inherit inputs; };
        };

    in {
      homeConfigurations = lib.mapAttrs (_: mkHome) configs;
    };
}
