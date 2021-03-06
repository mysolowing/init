
;; =============== Keys ===============
(global-set-key (kbd "C-q") 'suspend-emacs)
(global-set-key (kbd "M-q") 'toggle-read-only)
(global-set-key "\C-o" 'other-window)
(defalias 'redo 'undo-tree-redo)
(global-set-key "\C-z" 'undo)
(global-set-key "\C-y" 'redo)
(global-unset-key "\C-j")
(global-set-key "\C-j" 'backward-char)
(global-set-key "\C-k" 'forward-char)
(global-set-key (kbd "M-k") 'forward-word)
(global-set-key (kbd "M-j") 'backward-word)
(global-set-key (kbd "C-S-j") 'backward-word)
(global-set-key (kbd "C-S-k") 'forward-word)
(global-unset-key (kbd "C-x 2"))
(global-set-key (kbd "C-x 2") 'split-window-horizontally)
(global-set-key (kbd "M-o") 'delete-other-windows)
(global-set-key (kbd "C-v") 'yank)
(global-set-key (kbd "M-m") 'set-mark-command)
(define-key global-map (kbd "RET") 'newline-and-indent)
(global-unset-key (kbd "M-w"))
(global-set-key (kbd "M-w") 'delete-other-windows)
(global-set-key "\M-z" 'repeat-complex-command)
(global-unset-key (kbd "C-t"))
(global-unset-key (kbd "C-r"))
(global-set-key (kbd "C-r") 'set-mark-command)
(global-set-key (kbd "C-t") 'isearch-backward)
;; ----------------F Keys ------------------------

(global-unset-key [(f11)])
(global-set-key [(f11)]
		(lambda() (interactive) (find-file "~/init/emacs_basic.el")))
(global-set-key [(f12)] (lambda()
		(interactive)(save-some-buffers (buffer-file-name)) (eval-buffer))) ;; evaluate buffer

; The Backspace key: Control-? (127)
; The Home and End keys: Standard
; The Function keys and keypad: ESC[n~
; Emacs fix in putty
(define-key global-map "\M-[1~" 'beginning-of-line)
(define-key global-map [select] 'end-of-line)
;; =============== Functions and kbd ===============
;; ----------------------------------------
;; (global-set-key (kbd "M-l") (lambda() (interactive) (end-of-visual-line)(eval-last-sexp))
;; (global-set-key (kbd "M-l") 'eval-last-sexp)
;; ----------------------------------------
(global-set-key (kbd "M-n")     ; page down
  (lambda () (interactive)
    (condition-case nil (scroll-up)
      (end-of-buffer (goto-char (point-max))))))
(global-set-key (kbd "M-p")
  (lambda () (interactive) ; page up
    (condition-case nil (scroll-down)
      (beginning-of-buffer (goto-char (point-min))))))
(global-unset-key [(f9)])
(global-set-key [(f9)]	(lambda()(interactive) (switch-to-buffer "*scratch*")))
;; ----------------------------------------
(defun onekey-compile ()
   "Compile current buffer"
  (save-some-buffers (buffer-file-name))
  (interactive)
  (let (filename suffix progname compiler)
    (setq filename (file-name-nondirectory buffer-file-name))
    (setq progname (file-name-sans-extension filename))
    (setq suffix (file-name-extension filename))
    (if (string= suffix "c") (setq compiler (concat "gcc -std=c99 -g -Wall -o " progname " ")))


    (if (or (string= suffix "cc") (string= suffix "cpp"))
		(setq compiler (concat "g++ -g -Wall -std=c99 -o " progname " ")))
    (if (string= suffix "tex") (setq compiler "pdflatex "))
    (if (string= suffix "py") (setq compiler "python "))
    (if (string= suffix "sp") (setq compiler "hspice "))
    (if (string= suffix "el") (eval-buffer) (compile (concat compiler filename)))))
(global-unset-key (kbd "C-b"))
(global-set-key (kbd "C-b") 'onekey-compile)
;; ----------------------------------------
(defun comment-or-uncomment-region-or-line ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)))
(global-unset-key (kbd "C-_"))
(global-set-key (kbd "C-_") 'comment-or-uncomment-region-or-line)

;; set new method of kill a whole line
(defadvice kill-ring-save (before slickcopy activate compile)
  "When called interactively with no active region, copy a single line instead."
 (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))
(defadvice kill-region (before slickcut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defun copy-line (arg)
    "Copy lines (as many as prefix argument) in the kill ring.
      Ease of use features:
      - Move to start of next line.
      - Appends the copy on sequential calls.
      - Use newline as last char even on the last line of the buffer.
      - If region is active, copy its lines."
    (interactive "p")
    (let ((beg (line-beginning-position))
          (end (line-end-position arg)))
      (when mark-active
        (if (> (point) (mark))
            (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
          (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
      (if (eq last-command 'copy-line)
          (kill-append (buffer-substring beg end) (< end beg))
        (kill-ring-save beg end)))
    (kill-append "\n" nil)
    (beginning-of-line (or (and arg (1+ arg)) 2))
    (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))

(defun my-kill-ring-save (beg end flash)
      (interactive (if (use-region-p)
                       (list (region-beginning) (region-end) nil)
                     (list (line-beginning-position)
                           (line-beginning-position 2) 'flash)))
      (kill-ring-save beg end)
      (when flash
        (save-excursion
          (if (equal (current-column) 0)
              (goto-char end)
            (goto-char beg))
          (sit-for blink-matching-delay))))

(global-set-key [remap kill-ring-save] 'my-kill-ring-save)
(global-unset-key (kbd "C-f"))
(global-set-key (kbd "C-f") 'my-kill-ring-save)
