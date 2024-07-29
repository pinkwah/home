{ config, pkgs, ... }:

let

  emacs-config = with pkgs; ''
    ;; VTerm
    (setq! vterm-shell "~/.nix-profile/bin/fish")

    ;; Python
    (appendq! lsp-enabled-clients 'pyright)

    ;; C/C++
    (appendq! lsp-enabled-clients 'clangd)
    (setq! lsp-clients-clangd-executable "${clang-tools}/bin/clangd")

    ;; CMake
    (appendq! lsp-enabled-clients 'cmakels)
    (setq! lsp-cmake-server-command "${lib.getExe cmake-language-server}")

    ;; Nix
    (appendq! lsp-enabled-clients 'nixd-lsp)
    (setq! lsp-nix-nixd-server-path "${lib.getExe nixd}")

    ;; Yaml
    (appendq! lsp-enabled-clients 'yamlls)
    (setq! lsp-yaml-server-command '("${lib.getExe yaml-language-server}" "--stdio")

    ;; Typescript
    (appendq! lsp-enabled-clients 'ts-ls)
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
