{ config, pkgs, ... }:

let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
  });
in
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    nixvim.homeManagerModules.nixvim
  ];

  home.username = "zohar";
  home.homeDirectory = "/var/home/zohar";
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.file = {
  };

  home.sessionVariables = {
  };

  home.packages = with pkgs; [
    (import (fetchTarball https://install.devenv.sh/latest)).default

    # Misc
    cachix
    fd
    glab
    neovim-gtk
    yadm

    # Fonts
    hasklig

    # C / C++
    clang-tools

    # Python
    black
    pyright
    ruff

    # Javascript
    # nodejs_20
    # tree-sitter
  ];

  home.file.".config/doom/hm-custom.el" = {
    enable = true;
    text = with pkgs; ''
      (setq-default
        vterm-shell "~/.nix-profile/bin/fish"
        lsp-clients-clangd-executable "${clang-tools}/bin/clangd"
        lsp-cmake-server-command "${cmake-language-server}/bin/cmake-language-server"
        lsp-nix-nixd-server-path "${nixd}/bin/nixd"
        lsp-yaml-server-command '("${yaml-language-server}/bin/yaml-language-server" "--stdio")
      )
    '';
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
  # programs.nixvim = {
    # enable = true;

    # plugins.which-key.enable = true;
  # };

  programs.ripgrep.enable = true;
  programs.zellij.enable = true;
}
