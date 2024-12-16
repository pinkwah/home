{ lib, config, pkgs, ... }:

let

  nix-tools = import (pkgs.fetchFromGitHub {
    owner = "pinkwah";
    repo = "nix-tools";
    rev = "main";
    hash = "sha256-DZHsM+Nb7k3be9tuxQ4sio2mXutnmOZJf+qX6hkuzys=";
  });

  use-default = pkg: exe: pkgs.writeScript "default-${exe}" ''
    #!${lib.getExe pkgs.bash}
    if command -v "${exe}" 2>&1 >/dev/null
    then
      exec "${exe}" "$@"
    else
      exec "${pkg}/bin/${exe}" "$@"
    fi
  '';

  use-default' = pkg: use-default pkg (builtins.baseNameOf (lib.getExe pkg));

  emacs-config = with pkgs; ''
    ;; VTerm
    (setq! vterm-shell "~/.nix-profile/bin/fish"
           lsp-enabled-clients '(
             clangd
             cmakels
             nixd-lsp
             pyright
             rust-analyzer
             ruby-ls
             ts-ls
             yamlls
            ))

    ;; Python

    ;; C/C++
    (setq! lsp-clients-clangd-executable "${clang-tools}/bin/clangd")

    ;; CMake
    (setq! lsp-cmake-server-command "${lib.getExe cmake-language-server}")

    ;; Nix
    (setq! lsp-nix-nixd-server-path "${lib.getExe nixd}")

    ;; Ruby
    (setq! lsp-solargraph-server-command '("${use-default' solargraph}" "stdio"))

    ;; Rust
    (setq! lsp-rust-server "${lib.getExe rust-analyzer}"
           rustic-lsp-server "${lib.getExe rust-analyzer}")

    ;; Typescript
    (setq! lsp-clients-typescript-tls-path "${lib.getExe typescript-language-server}")

    ;; Yaml
    (setq! lsp-yaml-server-command '("${lib.getExe yaml-language-server}" "--stdio"))
  '';

  nixpkgs-script = pkgs.writeShellScriptBin "nixpkgs" ''
    #!$[lib.getExe pkgs.bash}
    nix eval --impure --expr "<nixpkgs>"
  '';

in {
  imports = [
    ./user.nix
  ];

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.overlays = [ nix-tools.overlays.default ];

  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Misc
    cachix
    devenv
    fd
    glab
    yadm
    htop
    nixpkgs-script

    # Fonts
    corefonts
    nerd-fonts.hasklug
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    vistafonts

    # C / C++
    conan
    meson
    ninja
    clang-tools  # clangd

    # Javascript
    nodejs
    typescript

    # Nix
    nixd

    # Python
    black
    poetry
    pyright
    ruff

    # Other
    nodejs
    # nix-tools.default
  ];

  home.file.".config/doom/hm-custom.el" = {
    enable = true;
    text = emacs-config;
  };
  
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
  programs.home-manager.enable = true;

  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  programs.jq.enable = true;
  programs.lsd.enable = true;

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ nvim-treesitter.withAllGrammars ];
  };

  programs.ripgrep.enable = true;
  programs.zellij.enable = true;
}
