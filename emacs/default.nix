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

  emacsConfig = with pkgs; ''
    ;; VTerm
    (setq! vterm-shell "~/.nix-profile/bin/fish"
           lsp-enabled-clients '(
             my-astro-ls
             clangd
             cmakels
             crystalline
             mesonlsp
             ruby-lsp-ls
             tailwindcss
             rust-analyzer
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

    ;; Lisp
    (setq! parinfer-rust-library "${parinfer-rust-emacs}/lib/libparinfer_rust.${soSuffix}")

    ;; Meson
    (setq! lsp-meson-server-executable '("${if stdenv.isDarwin then "" else lib.getExe mesonlsp}"))

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
    package = pkgs.emacs29-pgtk;
    extraPackages = epkgs: with epkgs; [
      tree-sitter
      tree-sitter-langs
      vterm
    ];
  };
}
