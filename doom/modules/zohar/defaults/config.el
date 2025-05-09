;;; spacemacs/defaults/config.el -*- lexical-binding: t; -*-
(defun spacemacs/indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (evil-indent (point-min) (point-max))
        (message "Indented buffer.")))
    (whitespace-cleanup)))

;; -----------------------------------------------------------------------------
;; BEGIN Align
;; -----------------------------------------------------------------------------

;; modified function from http://emacswiki.org/emacs/AlignCommands
(defun spacemacs/align-repeat (start end regexp &optional justify-right after)
  "Repeat alignment with respect to the given regular expression.
If JUSTIFY-RIGHT is non nil justify to the right instead of the
left. If AFTER is non-nil, add whitespace to the left instead of
the right."
  (interactive "r\nsAlign regexp: ")
  (let* ((ws-regexp (if (string-empty-p regexp)
                        "\\(\\s-+\\)"
                      "\\(\\s-*\\)"))
         (complete-regexp (if after
                              (concat regexp ws-regexp)
                            (concat ws-regexp regexp)))
         (group (if justify-right -1 1)))

    (unless (use-region-p)
      (save-excursion
        (while (and
                (string-match-p complete-regexp (thing-at-point 'line))
                (= 0 (forward-line -1)))
          (setq start (point-at-bol))))
      (save-excursion
        (while (and
                (string-match-p complete-regexp (thing-at-point 'line))
                (= 0 (forward-line 1)))
          (setq end (point-at-eol)))))

    (align-regexp start end complete-regexp group 1 t)))

;; Modified answer from http://emacs.stackexchange.com/questions/47/align-vertical-columns-of-numbers-on-the-decimal-point
(defun spacemacs/align-repeat-decimal (start end)
  "Align a table of numbers on decimal points and dollar signs (both optional)"
  (interactive "r")
  (require 'align)
  (align-region start end nil
                '((nil (regexp . "\\([\t ]*\\)\\$?\\([\t ]+[0-9]+\\)\\.?")
                       (repeat . t)
                       (group 1 2)
                       (spacing 1 1)
                       (justify nil t)))
                nil))

(defmacro spacemacs|create-align-repeat-x (name regexp &optional justify-right default-after)
  (let* ((new-func (intern (concat "spacemacs/align-repeat-" name)))
         (new-func-defn
          `(defun ,new-func (start end switch)
             (interactive "r\nP")
             (let ((after (not (eq (if switch t nil) (if ,default-after t nil)))))
               (spacemacs/align-repeat start end ,regexp ,justify-right after)))))
    (put new-func 'function-documentation "Created by `spacemacs|create-align-repeat-x'.")
    new-func-defn))

(spacemacs|create-align-repeat-x "comma" "," nil t)
(spacemacs|create-align-repeat-x "semicolon" ";" nil t)
(spacemacs|create-align-repeat-x "colon" ":" nil t)
(spacemacs|create-align-repeat-x "equal" "=")
(spacemacs|create-align-repeat-x "math-oper" "[+\\-*/]")
(spacemacs|create-align-repeat-x "percent" "%")
(spacemacs|create-align-repeat-x "ampersand" "&")
(spacemacs|create-align-repeat-x "bar" "|")
(spacemacs|create-align-repeat-x "left-paren" "(")
(spacemacs|create-align-repeat-x "right-paren" ")" t)
(spacemacs|create-align-repeat-x "left-curly-brace" "{")
(spacemacs|create-align-repeat-x "right-curly-brace" "}" t)
(spacemacs|create-align-repeat-x "left-square-brace" "\\[")
(spacemacs|create-align-repeat-x "right-square-brace" "\\]" t)
(spacemacs|create-align-repeat-x "backslash" "\\\\")

;; keybinds --------------------------------------------------------------------

(map! :leader
      (:prefix-map ("x" . "text")
       (:prefix ("a" . "align")
        "%" #'spacemacs/align-repeat-percent
        "&" #'spacemacs/align-repeat-ampersand
        "(" #'spacemacs/align-repeat-left-paren
        ")" #'spacemacs/align-repeat-right-paren
        "{" #'spacemacs/align-repeat-left-curly-brace
        "}" #'spacemacs/align-repeat-right-curly-brace
        "[" #'spacemacs/align-repeat-left-square-brace
        "]" #'spacemacs/align-repeat-right-square-brace
        "," #'spacemacs/align-repeat-comma
        "." #'spacemacs/align-repeat-period
        ":" #'spacemacs/align-repeat-colon
        ";" #'spacemacs/align-repeat-semicolon
        "=" #'spacemacs/align-repeat-equal
        "\\" #'spacemacs/align-repeat-backslash
        "a" #'align
        "c" #'align-current
        "m" #'spacemacs/align-repeat-math-oper
        "r" #'spacemacs/align-repeat
        "|" #'spacemacs/align-bar)))

;; -----------------------------------------------------------------------------
;; END Align
;; -----------------------------------------------------------------------------

;; format ---------------------------------------------------------------------
(map! :leader
      :prefix ("j" . "format")
      :desc "Check unclosed parens" "(" #'check-parens
      :desc "Indent region or buffer" "=" #'spacemacs/indent-region-or-buffer)
