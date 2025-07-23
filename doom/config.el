;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(let ((doom-config (expand-file-name "~/.config/home-manager/doom-config.el")))
  (setq! doom-module-config-file doom-config)
  (load! doom-config))
