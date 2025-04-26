{ lib, pkgs, ... }:

let
  soSuffix = if pkgs.stdenv.isDarwin then "dylib" else "so";

  use-default' = pkg: use-default pkg (builtins.baseNameOf (lib.getExe pkg));

  use-default = pkg: exe: pkgs.writeScript "default-${exe}" ''
    #!${lib.getExe pkgs.bash}
    if command -v "${exe}" 2>&1 >/dev/null
    then
      exec "${exe}" "$@"
    else
      exec "${pkg}/bin/${exe}" "$@"
    fi
  '';

  allGrammars =
    let
      grammars = lib.filterAttrs (k: v: lib.isDerivation v) pkgs.tree-sitter-grammars;
      names = lib.concatStringsSep " " (lib.attrNames grammars);
      paths = lib.concatStringsSep " " (lib.attrValues grammars);
    in pkgs.runCommand "emacs-tree-sitter-grammars" {
        inherit names paths;
      } ''
      mkdir -p $out/lib
      n=($names)
      p=($paths)
      l=''${#p[@]}
      for ((i=0;i<$l;i++)); do
        ln -s "''${p[$i]}/parser" "$out/lib/lib''${n[$i]}.so"
      done
    '';

  crystalline = pkgs.callPackage ../pkgs/crystalline {};

  emacsConfig = with pkgs; ''
    ;; Astro
    (after! lsp-mode
      (lsp-register-client
        (make-lsp-client
        :new-connection (lsp-stdio-connection '("${astro-language-server}/bin/astro-ls" "--stdio"))
        :major-modes '(astro-ts-mode)
        :server-id 'my-astro-ls
          :activation-fn (lsp-activate-on "astro")
          :initialization-options '(:typescript (:tsdk "${typescript}/lib/node_modules/typescript/lib")))))

    ;; Lisp
    (setq! parinfer-rust-library "${parinfer-rust-emacs}/lib/libparinfer_rust.${soSuffix}")

    ;; Meson
    (setq! lsp-meson-server-executable '("${if stdenv.isDarwin then "" else lib.getExe mesonlsp}"))

    ;; Setup PATH
    (add-to-list 'exec-path (concat (xdg-data-home) "/emacs-lsps/bin"))
    (setenv "PATH" (mapconcat 'identity exec-path ":"))
  '';

  lsps = with pkgs; {
    inherit (pkgs)
      pyright
      cmake-language-server
      crystalline
      kotlin-language-server
      nixd
      intelephense
      rust-analyzer
      tailwindcss-language-server
      typescript
      typescript-language-server
      vala-language-server
      yaml-language-server;

    # pyright = basedpyright;
    clangd = clang-tools;
  };

  lspsEnv = pkgs.buildEnv {
    name = "lsps-env";
    paths = lib.attrValues lsps;
  };

  # lspsEnv = pkgs.runCommand "lsps-env" {
    # paths = builtins.toJSON (lib.mapAttrs (k: v: lib.getExe v) lsps);
# 
    # script = ''
    # import os
    # import json
    # # from pathlib import Path
# # 
    # out = Path(os.environ["out"])
    # (out / "bin").mkdir(parents=True)
    # for name, path in json.loads(os.environ["paths"]).items():
        # (out / "bin" / name).symlink_to(path)
    # '';
  # } ''
    # echo "$script" | ${pkgs.python3}/bin/python3
  # '';

in

{
  home.file.".config/doom/hm-custom.el" = {
    enable = true;
    text = emacsConfig;
  };

  home.file.".local/share/emacs-lsps" = {
    enable = true;
    source = lspsEnv;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;
    extraPackages = epkgs: with epkgs; [
      tree-sitter
      tree-sitter-langs
      vterm
      allGrammars
    ];
  };
}
