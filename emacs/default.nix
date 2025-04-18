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

  rubyEnv = pkgs.bundlerEnv {
    name = "emacs-ruby-env";
    gemdir = ./.;
  };

  crystalline = pkgs.callPackage ./crystalline.nix {};

  emacsConfig = with pkgs; ''
    ;; VTerm
    (setq! vterm-shell "~/.nix-profile/bin/fish"
           lsp-enabled-clients '(
             clangd
             cmakels
             crystalline
             iph
             kotlin-ls
             mesonlsp
             my-astro-ls
             pyright
             ruby-lsp-ls
             ;; ruby-ls
             rust-analyzer
             tailwindcss
             ts-ls
             valals
             yamlls
            ))

    ;; Astro
    (after! lsp-mode
      (lsp-register-client
        (make-lsp-client
        :new-connection (lsp-stdio-connection '("${astro-language-server}/bin/astro-ls" "--stdio"))
        :major-modes '(astro-ts-mode)
        :server-id 'my-astro-ls
          :activation-fn (lsp-activate-on "astro")
          :initialization-options '(:typescript (:tsdk "${typescript}/lib/node_modules/typescript/lib")))))

    ;; Python
    (setq lsp-pyright-langserver-command "${lib.getExe basedpyright}"
          dap-python-debugger 'debugpy)

    ;; C/C++
    (setq! lsp-clients-clangd-executable "${clang-tools}/bin/clangd")

    ;; CMake
    (setq! lsp-cmake-server-command "${lib.getExe cmake-language-server}")

    ;; Crystal
    (setq! lsp-clients-crystal-executable '("${lib.getExe crystalline}" "--stdio"))

    ;; Kotlin
    (setq! lsp-clients-kotlin-server-executable "${kotlin-language-server}/bin/kotlin-language-server"
           lsp-kotlin-language-server-path "${kotlin-language-server}/bin/kotlin-language-server")

    ;; Lisp
    (setq! parinfer-rust-library "${parinfer-rust-emacs}/lib/libparinfer_rust.${soSuffix}")

    ;; Meson
    (setq! lsp-meson-server-executable '("${if stdenv.isDarwin then "" else lib.getExe mesonlsp}"))

    ;; Nix
    (setq! lsp-nix-nixd-server-path "${lib.getExe nixd}")

    ;; PHP
    (setq! lsp-intelephense-server-command '("${lib.getExe intelephense}" "--stdio"))

    ;; Ruby
    ;; (setq! lsp-solargraph-server-command '("${use-default rubyEnv "solargraph"}" "stdio"))

    ;; Rust
    (setq! lsp-rust-server "${lib.getExe rust-analyzer}"
           rustic-lsp-server "${lib.getExe rust-analyzer}")

    ;; TailwindCSS
    (setq! lsp-tailwindcss-server-path "${lib.getExe tailwindcss-language-server}")

    ;; Typescript
    (setq! lsp-clients-typescript-tls-path "${lib.getExe typescript-language-server}"
           lsp-typescript-tsdk "${typescript}/lib/node_modules/typescript")

    ;; Vala
    (setq! lsp-clients-vala-ls-executable "${lib.getExe vala-language-server}")

    ;; Yaml
    (setq! lsp-yaml-server-command '("${lib.getExe yaml-language-server}" "--stdio"))
  '';

in

{
  home.file.".config/doom/hm-custom.el" = {
    enable = true;
    text = emacsConfig;
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
