;; -*- no-byte-compile: t; -*-
;;; lang/astro/packages.el

(package! astro-ts-mode)

(when (modulep! +lsp)
  (package! lsp-tailwindcss
    :recipe (:host github :repo "merrickluo/lsp-tailwindcss")))
