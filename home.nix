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

      tailwindcss-language-server = prev.callPackage ./pkgs/tailwindcss-language-server {};
    })
  ];

  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Misc
    attic-client
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
    jq
    yq

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

    # Ruby
    ruby

    # Language Server Protocol(s)
    clang-tools                  # C/C++
    nil                          # Nix
    basedpyright                 # Python
    rust-analyzer                # Rust
    yaml-language-server         # YAML
    vscode-langservers-extracted # CSS, EsLint, HTML, JSON, Markdown
    typescript-language-server   # {Java,Type}script
    tailwindcss-language-server  # TailwindCSS

    # Typescript
    typescript
  ];
}
