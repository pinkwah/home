{ lib, config, pkgs, inputs, ... }:

let

  nix-tools = import (pkgs.fetchFromGitHub {
    owner = "pinkwah";
    repo = "nix-tools";
    rev = "main";
    hash = "sha256-DZHsM+Nb7k3be9tuxQ4sio2mXutnmOZJf+qX6hkuzys=";
  });

  tree-sitter-astro = pkgs.tree-sitter.buildGrammar {
    language = "astro";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "virchau13";
      repo = "tree-sitter-astro";
      rev = "6e3bad36a8c12d579e73ed4f05676141a4ccf68d";
      hash = "sha256-ZsItSpYeSPnHn4avpHS54P4J069X9cW8VCRTM9Gfefg=";
    };
  };

  nixpkgs-script = pkgs.writeShellScriptBin "nixpkgs" ''
    #!${lib.getExe pkgs.bash}
    nix repl -f ${inputs.nixpkgs}
  '';

  nixpkgs-src-script = pkgs.writeShellScriptBin "nixpkgs-src" ''
    #!${lib.getExe pkgs.bash}
    echo "${inputs.nixpkgs}"
  '';

  mkEmacsTreeSitterGrammar = grammar: pkgs.stdenv.mkDerivation {
    inherit (grammar) version meta src;
    pname = "${grammar.pname}-emacs";

    buildPhase = ''
      [[ -f $src/src/parser.c ]] && $CC -fPIC -c -I$src/src parser.c
      [[ -f $src/src/scanner.c ]] && $CC -fPIC -c -I$src/src scanner.c
      [[ -f $src/src/scanner.cc ]] && $CXX -fPIC -c -I$src/src scanner.cc

      if [[ -f $src/src/scanner.cc ]]; then
        $CXX -fPIC -shared *.o lib${grammar.pname}.so
      else
        $CC -fPIC -shared *.o lib${grammar.pname}.so
      fi
    '';
  };

  allEmacsTreeSitterGrammars = lib.mapAttrsFlatten (_: g: mkEmacsTreeSitterGrammar g ) pkgs.tree-sitter-grammars;

in {
  imports = [
    ./user.nix
    ./emacs
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    # nix-tools.overlays.default
    (final: prev: {
      tree-sitter = prev.tree-sitter.override {
        extraGrammars = { inherit tree-sitter-astro; };
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
    tmux
    nixpkgs-script
    nixpkgs-src-script

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
  programs.zellij.enable = true;
}
