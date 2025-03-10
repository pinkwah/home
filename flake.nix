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
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      os = import ./os.nix;
    in {
      homeConfigurations.${os.name} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit (os) system; };

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          inputs.mac-app-util.homeManagerModules.default
          inputs.nix-index-database.hmModules.nix-index
          ./home.nix
          os.module
          {
            home.username = os.name;
            home.homeDirectory = os.home;
          }
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
