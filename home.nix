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

  home.stateVersion = "25.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Misc
    cachix
    devenv
    fd
    glab
    yadm
    htop
    nixpkgsScript
    dos2unix
    jq
    yq
    socat

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    corefonts
    vista-fonts

    # Language Server Protocol(s)
    astro-language-server        # Astro.build
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
