{ config, pkgs, ... }:

let

  emacs-config = with pkgs; ''
    ;; VTerm
    (setq! vterm-shell "~/.nix-profile/bin/fish"
           lsp-enabled-clients '(
             pyright
             clangd
             cmakels
             nixd-lsp
             yamlls
             ts-ls
            ))

    ;; Python

    ;; C/C++
    (setq! lsp-clients-clangd-executable "${clang-tools}/bin/clangd")

    ;; CMake
    (setq! lsp-cmake-server-command "${lib.getExe cmake-language-server}")

    ;; Nix
    (setq! lsp-nix-nixd-server-path "${lib.getExe nixd}")

    ;; Yaml
    (setq! lsp-yaml-server-command '("${lib.getExe yaml-language-server}" "--stdio"))

    ;; Typescript
    (setq! lsp-clients-typescript-tls-path "${lib.getExe typescript-language-server}")
  '';

in {
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    # Misc
    cachix
    devenv
    fd
    glab
    neovim-gtk
    yadm
    htop
    btop

    # Fonts
    hasklig
    (nerdfonts.override { fonts = ["NerdFontsSymbolsOnly"]; })

    # C / C++
    clang-tools  # clangd

    # Javascript
    typescript

    # Ruby
    ruby

    # Nix
    nixd

    # Python
    black
    pyright
    ruff
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
    # package = pkgs.emacs29-pgtk;
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
