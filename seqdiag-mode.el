;; seqdiag-mode.el -- Major mode for seqdiag

;; Author: Shunichi Shinohara

;;;; TODO
;;
;; * Group appropreately keywords, builtins and so on.
;; * Execute seqdiag command and view result in buffer or launch appropriate viewer.
;; * Auto indent (seems difficult ...).
;; * Highlight or complete node labels.
;; * Highlight or some treatment for arrows like <-, ->, --> and so on..

(defgroup seqdiag-mode nil
  "Major mode for editing seqdiag file."
  :group 'languages)

(defvar seqdiag-mode-hook nil "Standard hook for seqdiag-mode.")
(defvar seqdiag-mode-map nil "Keymap for seqdiag-mode")

(defvar seqdiag-command "seqdiag")
(defvar seqdiag-command-options "")
(defvar seqdiag-pdf-open-command "open")

;;;; syntax table
;; I don't know anything about this :-/
(defvar seqdiag-mode-syntax-table
  nil
  "Syntax table for `seqdiag-mode'.")

(setq seqdiag-mode-syntax-table
      (make-syntax-table c-mode-syntax-table))
(let ((synTable seqdiag-mode-syntax-table))
;;   (modify-syntax-entry ?= "< b" synTable)
;;   (modify-syntax-entry ?' "< b" synTable)
;;   (modify-syntax-entry ?\n "> b" synTable)
;;   (modify-syntax-entry ?! "w" synTable)
;;   (modify-syntax-entry ?@ "w" synTable)
;;   (modify-syntax-entry ?# "'" synTable)
  synTable)

(defvar seqdiag-types nil)
(defvar seqdiag-keywords '("autonumber" "default_note_color" "activation" "<-"))
;; (defvar seqdiag-types '("autonumber" "label"))
;; (defvar seqdiag-keywords '())

(setq seqdiag-types '())
(setq seqdiag-builtin '("True" "none" "lightblue"))
(setq seqdiag-keywords '("diagram"

                         ;; diagram attributes
                         "edge_length" "span_height" 
                         "default_fontsize"
                         "autonumber" "default_note_color"
                         "activation"

                         ;; attributes of edges
                         "label" "diagonal" "failed" "color"
                         "leftnote" "rightnote"
                         "return"
                         "<-"))

(setq seqdiag-types-regexp
      (concat
       (regexp-opt seqdiag-types 'words)
       ""))
(setq seqdiag-keywords-regexp (regexp-opt seqdiag-keywords 'words))
(setq seqdiag-builtin-regexp
      (concat
       (regexp-opt seqdiag-builtin 'words)
       "\\|\\<[0-9]+\\>"))
(setq seqdiag-preprocessor-regexp "")
(setq seqdiag-function-name-regexp "")

(setq seqdiag-font-lock-keywords
      `(
        (,seqdiag-types-regexp . font-lock-type-face)
        (,seqdiag-keywords-regexp . font-lock-keyword-face)
        (,seqdiag-builtin-regexp . font-lock-builtin-face)
        (,seqdiag-preprocessor-regexp . font-lock-preprocessor-face)
        (,seqdiag-function-name-regexp . font-lock-function-name-face)
        ;; note: order matters
        ))

(defface hi-darkgreen-b
  '((t (:weight bold :foreground "#33AA33")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defun seqdiag-highlight-separator-lines ()
  (interactive)
  (highlight-lines-matching-regexp "^ *===.*=== *$" 'hi-blue-b)
  (highlight-lines-matching-regexp "^ *\\.\\.\\..*\\.\\.\\. *$" 'hi-darkgreen-b)
)

(defun seqdiag-compile ()
  (interactive)
  (let ((command (seqdiag-compile-command-line))))
    (message command)
    (shell-command command)
    )

(defun seqdiag-compile-command-line ()
  (interactive)
  (concat seqdiag-command
          " "
          seqdiag-command-options
          " "
          (buffer-file-name (current-buffer)))
  )

(defun seqdiag-compile-open ()
  (interactive)
  (seqdiag-compile)
  (let ((command (seqdiag-pdf-open-command-line)))
    (shell-command command)
  ))

(defun seqdiag-pdf-open-command-line ()
  (interactive)
  (concat
   seqdiag-pdf-open-command
   " "
   (file-name-sans-extension (buffer-file-name (current-buffer)))
   ".pdf"))

;;;###autoload

(defun seqdiag-mode ()
  "Major mode for seqdiag."

  (interactive)
  (kill-all-local-variables)

  (setq major-mode 'seqdiag-mode
        mode-name "seqdiag")
  (set-syntax-table seqdiag-mode-syntax-table)
  (use-local-map seqdiag-mode-map)
  (setq comment-start "//")

  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '((seqdiag-font-lock-keywords) nil t))
  (hi-lock-mode 1)
  (seqdiag-highlight-separator-lines)
  (setq compile-command (concat
                         (seqdiag-compile-command-line)
                         " && "
                         (seqdiag-pdf-open-command-line)))

  (run-mode-hooks 'seqdiag-mode-hook)
)

(provide 'seqdiag-mode)
