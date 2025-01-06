{
  description = "Home Manager configuration of zohar";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-index-database, ... }:
    {
      homeConfigurations.${builtins.getEnv "USER"} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {};

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ nix-index-database.hmModules.nix-index ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
