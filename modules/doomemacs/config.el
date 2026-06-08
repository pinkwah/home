;;; -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Zohar Malamant"
      user-mail-address "me@wah.pink")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(if (featurep :system 'macos)
    (setq doom-font "JetBrainsMono NFM-16"
          doom-emoji-font "Apple Color Emoji")
  (setq doom-font "JetBrainsMono NFM-14"
        doom-emoji-font "Noto Color Emoji"))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(defcustom my-use-dark-theme t
  "If non-nil, use dark theme, otherwise light theme"
  :type 'boolean
  :group 'my-doom-themes)

(setq my-light-theme 'doom-winter-is-coming-light
      my-dark-theme 'doom-ir-black)
(setq doom-theme (if my-use-dark-theme my-dark-theme my-light-theme))

(defun my-toggle-theme ()
  "Toggle between light and dark theme"
  (interactive)
  (load-theme (if my-use-dark-theme my-light-theme my-dark-theme) t)
  (setq my-use-dark-theme (not my-use-dark-theme)))

(map! :leader
      :desc "Toggle between light and dark theme" "t t" #'my-toggle-theme)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Set splash image to be that of my fursona
(setq fancy-splash-image (concat doom-private-dir "banner-320.png"))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(map! :leader
      :desc "Select window 1" "1" #'winum-select-window-1
      :desc "Select window 2" "2" #'winum-select-window-2
      :desc "Select window 3" "3" #'winum-select-window-3
      :desc "Select window 4" "4" #'winum-select-window-4
      :desc "Select window 5" "5" #'winum-select-window-5
      :desc "Select window 6" "6" #'winum-select-window-6
      :desc "Select window 7" "7" #'winum-select-window-7
      :desc "Select window 8" "8" #'winum-select-window-8
      :desc "Select window 9" "9" #'winum-select-window-9
      :desc "Switch to last buffer" "TAB" #'evil-switch-to-windows-last-buffer
      :desc "Switch to last buffer" "DEL" #'evil-switch-to-windows-last-buffer
      :desc "Select Treemacs window" "`" #'treemacs-select-window
      :desc "Select Treemacs window" "ESC" #'treemacs-select-window)

(map! :leader
      :prefix ("g" . "git")
      :desc "Magit status" "s" #'magit-status
      :desc "Git blame" "b" #'magit-blame)

(after! treemacs
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action))

(with-eval-after-load 'evil
  (defalias #'forward-evil-word #'forward-evil-symbol))

(after! vala-mode
  (add-hook 'vala-mode-hook #'lsp!))

(setq! lsp-enable-file-watchers nil)

(setq! major-mode-remap-alist
       '((c++-mode . c++-ts-mode)
         (c-or-c++-mode . c-or-c++-ts-mode)
         (c-mode . c-ts-mode)
         (cmake-mode . cmake-ts-mode)
         (csharp-mode . csharp-ts-mode)
         (css-mode . css-ts-mode)
         (dockerfile-mode . dockerfile-ts-mode)
         (elixir-mode . elixir-ts-mode)
         (go-mod-mode . go-mod-ts-mode)
         (go-mode . go-ts-mode)
         (heex-mode . heex-ts-mode)
         (html-mode . html-ts-mode)
         (java-mode . java-ts-mode)
         (js-mode . js-ts-mode)
         (json-mode . json-ts-mode)
         (lua-mode . lua-ts-mode)
         (php-mode . php-ts-mode)
         (python-mode . python-ts-mode)
         (ruby-mode . ruby-ts-mode)
         (rust-mode . rust-ts-mode)
         (toml-mode . toml-ts-mode)
         (tsx-mode . tsx-ts-mode)
         (typescript-mode . typescript-ts-mode)
         (yaml-mode . yaml-ts-mode)))

(add-hook! 'bash-ts-mode-hook #'lsp! 'append)
(add-hook! 'c++-ts-mode-hook #'lsp! 'append)
(add-hook! 'c-or-c++-ts-mode-hook #'lsp! 'append)
(add-hook! 'c-ts-mode-hook #'lsp! 'append)
(add-hook! 'cmake-ts-mode-hook #'lsp! 'append)
(add-hook! 'csharp-ts-mode-hook #'lsp! 'append)
(add-hook! 'css-ts-mode-hook #'lsp! 'append)
(add-hook! 'dockerfile-ts-mode-hook #'lsp! 'append)
(add-hook! 'elixir-ts-mode-hook #'lsp! 'append)
(add-hook! 'go-mod-ts-mode-hook #'lsp! 'append)
(add-hook! 'go-ts-mode-hook #'lsp! 'append)
(add-hook! 'heex-ts-mode-hook #'lsp! 'append)
(add-hook! 'html-ts-mode-hook #'lsp! 'append)
(add-hook! 'java-ts-mode-hook #'lsp! 'append)
(add-hook! 'js-ts-mode-hook #'lsp! 'append)
(add-hook! 'json-ts-mode-hook #'lsp! 'append)
(add-hook! 'lua-ts-mode-hook #'lsp! 'append)
(add-hook! 'php-ts-mode-hook #'lsp! 'append)
(add-hook! 'python-ts-mode-hook #'lsp! 'append)
(add-hook! 'ruby-ts-mode-hook #'lsp! 'append)
(add-hook! 'rust-ts-mode-hook #'lsp! 'append)
(add-hook! 'toml-ts-mode-hook #'lsp! 'append)
(add-hook! 'tsx-ts-mode-hook #'lsp! 'append)
(add-hook! 'typescript-ts-mode-hook #'lsp! 'append)
(add-hook! 'yaml-ts-mode-hook #'lsp! 'append)

(setq! lsp-enable-suggest-server-download nil)

(use-package! lsp-tailwindcss
  :after lsp-mode
  :init
  (setq! lsp-tailwindcss-add-on-mode t))

(use-package! lsp-pyright
  :custom (lsp-pyright-langserver-command "basedpyright"))

;; (use-package! justl
;;  :config
;;  (map! :n "e" 'justl-exec-recipe))

;;;###autoload
(defun doom/find-file-in-private-config ()
  "Search for a file in `doom-user-dir'."
  (interactive)
  (doom-project-find-file (expand-file-name "~/.config/home-manager/doom")))

(doom-load-envvars-file (expand-file-name "~/.config/doom-init-env.el"))

(setq! visual-fill-column-width 120)
(add-hook! 'text-mode-hook #'visual-fill-column-mode)

(setq! vterm-shell (expand-file-name "~/.nix-profile/bin/fish"))

(use-package! ef-themes
  :init (ef-themes-take-over-modues-themes-mode 1)
  :config (setq modus-themes-mixed-fonts t modues-themes-italic-constructs t))
