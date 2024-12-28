{ lib, config, pkgs, ... }:

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
             my-astro-ls
             clangd
             cmakels
             crystalline
             nixd-lsp
             pyright
             ruby-lsp-ls
             rust-analyzer
             tailwindcss
             ts-ls
             yamlls
            ))

    ;; Astro
    (after! lsp-mode
      (lsp-register-client
        (make-lsp-client :new-connection (lsp-stdio-connection '("${astro-language-server}/bin/astro-ls" "--stdio"))
                         :activation-fn (lsp-activate-on "astro")
                         :initialization-options '(:typescript (:tsdk "${typescript}/lib/node_modules/typescript/lib"))
                         :server-id 'my-astro-ls)))

    ;; Python
    (setq lsp-pyright-langserver-command "${lib.getExe basedpyright}"
          dap-python-debugger 'debugpy)

    ;; C/C++
    (setq! lsp-clients-clangd-executable "${clang-tools}/bin/clangd")

    ;; CMake
    (setq! lsp-cmake-server-command "${lib.getExe cmake-language-server}")

    ;; Crystal
    (setq! lsp-clients-crystal-executable '("${lib.getExe crystalline}" "--stdio"))

    ;; Lisp
    (setq! parinfer-rust-library "${parinfer-rust-emacs}/lib/libparinfer_rust.so")

    ;; Nix
    (setq! lsp-nix-nixd-server-path "${lib.getExe nixd}")

    ;; Ruby
    (setq! lsp-solargraph-server-command '("${use-default' solargraph}" "stdio"))

    ;; Rust
    (setq! lsp-rust-server "${lib.getExe rust-analyzer}"
           rustic-lsp-server "${lib.getExe rust-analyzer}")

    ;; TailwindCSS
    (setq! lsp-tailwindcss-server-path "${lib.getExe tailwindcss-language-server}")

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

    # Other
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
    extraPackages = epkgs: with epkgs; [
      tree-sitter
      tree-sitter-langs
      vterm
    ];
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
