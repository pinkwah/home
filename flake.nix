{
  description = "Home Manager configuration of zohar";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
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
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs) lib;

      profiles = {
        zohar = {
          system = "x86_64-linux";
          username = "zohar";
          homeDirectory = "/var/home/zohar";
        };

        ZOM = {
          system = "aarch64-darwin";
          username = "ZOM";
          homeDirectory = "/Users/ZOM";
          modules = [ inputs.mac-app-util.homeManagerModules.default ./profiles/work-managed-macos.nix ];
        };
      };

      mkHome = { system, username, homeDirectory, modules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = modules ++ [
            inputs.nix-index-database.hmModules.nix-index
            inputs.doom-emacs.homeModule
            ./home.nix
            { home = { inherit username homeDirectory; }; }
          ];
          extraSpecialArgs = { inherit inputs; };
        };

    in {
      homeConfigurations = lib.mapAttrs (_: mkHome) profiles;
    };
}
