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
    dos2unix

    # Fonts
    nerd-fonts.hasklug
    nerd-fonts.jetbrains-mono
    nerd-fonts.blex-mono
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
    uv

      nil
      pyright
      yaml-language-server
      clang-tools
      rust-analyzer

    # Typescript
    typescript
  ];

  fonts.fontconfig.enable = true;

  programs.fish.enable = true;
  programs.gh.enable = true;

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

  programs.home-manager = {
    enable = true;
  };

  programs.jq.enable = true;
  programs.lsd.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.ripgrep.enable = true;

  programs.doom-emacs = {
    enable = true;
    emacs = pkgs.emacs30-pgtk;
    doomDir = ./doom;

    extraPackages = epkgs: with epkgs; [
      treesit-grammars.with-all-grammars
    ];
  };

  programs.vim.enable = true;
}
