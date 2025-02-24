{ lib, config, pkgs, inputs, ... }:

let

  nix-tools = import (pkgs.fetchFromGitHub {
    owner = "pinkwah";
    repo = "nix-tools";
    rev = "main";
    hash = "sha256-DZHsM+Nb7k3be9tuxQ4sio2mXutnmOZJf+qX6hkuzys=";
  });

  nixpkgsScript = pkgs.callPackage ./nixpkgs-script.nix { inherit inputs; };

in {
  imports = [
    ./user.nix
    ./emacs
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      tree-sitter = prev.tree-sitter.override {
        extraGrammars = import ./tree-sitter-grammars.nix { inherit (prev) lib fetchFromGitHub tree-sitter; };
      };
    })
  ];

  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Misc
    cachix
    devenv
    fd
    glab
    yadm
    htop
    btop
    tmux
    nixpkgsScript

    # Azure
    azure-cli

    # Fonts
    nerd-fonts.hasklug
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-emoji
    corefonts
    vistafonts
    jetbrains-mono

    # C / C++
    conan
    meson
    ninja

    # Python
    black
    poetry
    ruff

    # Typescript
    typescript
  ];

  fonts.fontconfig.enable = true;

  programs.fish.enable = true;
  programs.gh.enable = true;

  programs.gpg.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "/build"
      "/build-*"
      "/venv"
      "/venv-*"
    ];
  };

  programs.direnv.enable = true;
  programs.home-manager.enable = true;

  programs.jq.enable = true;
  programs.lsd.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.ripgrep.enable = true;
}
