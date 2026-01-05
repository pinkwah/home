{
  description = "Home Manager configuration of zohar";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doom-emacs = {
      url = "github:marienz/nix-doom-emacs-unstraightened/lsp-use-plists";
      inputs.nixpkgs.follows = "";
    };
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
            inputs.doom-emacs.homeModule
            ./home.nix
            { home = { inherit username homeDirectory; }; }
          ];
          extraSpecialArgs = { inherit inputs; };
        };

    in {
      homeConfigurations = lib.mapAttrs (_: mkHome) configs;
    };
}
