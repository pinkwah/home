{ config, pkgs, ... }:

{
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
    yadm

    # Fonts
    hasklig

    # C / C++
    clang-tools

    # Python
    black
    pyright
    ruff
  ];
  
  fonts.fontconfig.enable = true;

  programs.fish.enable = true;
  programs.gh.enable = true;

  programs.git = {
    enable = true;
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
  programs.neovim.enable = true;
  programs.nix-index.enable = true;
  programs.ripgrep.enable = true;
  programs.zellij.enable = true;
}
