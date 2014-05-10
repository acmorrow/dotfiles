(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(elisp-cache-byte-compile-files t)
 '(gdb-many-windows t t)
 '(gud-gdb-command-name "gdb -i=mi")
 '(user-mail-address "andrew.morrow@10gen.com")
 '(xgen-cru-auto-cc-list '())
 '(xgen-cru-upload-custom-args (quote ("--jira_user=acm")))
 '(xgen-cru-upload-py-path "/Users/andrew/Documents/10gen/dev/kernel-tools/codereview/upload.py"))

(setq ns-command-modifier 'meta)

(require 'package)
(package-initialize)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/"))

(require 'vc-hg)
(require 'vc-git)
(require 'vc-svn)

(global-git-gutter-mode t)

(require 'color-theme)
(add-to-list 'custom-theme-load-path "/Users/Andrew/.emacs.d/themes")
(load-theme 'solarized t t)
(color-theme-solarized-dark)
;; (color-theme-comidia)

;; TODO(acm): It would be nice to re-enable this someday
;; (add-hook 'after-make-frame-functions 'run-after-make-frame-hooks)
;; (add-hook 'after-init-hook
;;          (lambda ()
;;            (run-after-make-frame-hooks (selected-frame))))

;; (set-variable 'color-theme-is-global nil)
;; (add-hook 'after-make-window-system-frame-hooks 'color-theme-jonadabian)
;; (add-hook 'after-make-console-frame-hooks 'color-theme-arjen)

(require 'cmake-mode)
(require 'markdown-mode)

;; NOTE(acm): This messes up IDO
;; (ffap-bindings)

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

(require 'iedit)
(require 'ag)

(setq inhibit-splash-screen t)
(global-font-lock-mode t)
(setq-default transient-mark-mode t)


(setq-default indent-tabs-mode nil)
(setq ruby-indent-level 2)
(setq lua-indent-level 2)
(setq javascript-indent-level 2)
(setq python-indent-level 4)
(setq c-default-style "BSD")
(setq c-basic-offset 4)
;; NOTE(acm): 10gen doesn't indent in namespaces
(c-set-offset 'innamespace 4)

(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files"
  (interactive)
  (let* ((list (buffer-list))
         (buffer (car list)))
    (while buffer
      (when (buffer-file-name buffer)
        (progn
          (set-buffer buffer)
          (revert-buffer t t t)))
      (setq list (cdr list))
      (setq buffer (car list))))
  (message "Refreshing open files"))

;; show trailing whitespace
(setq-default show-trailing-whitespace t)

;; Nicer behavior when coding
;; (electric-indent-mode 0)

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

;; Disable frame kill that is too close to frame switch
(global-unset-key (kbd "C-x 5 0"))

;; Athena: use full filename in frame titles
;;(setq frame-title-format (list "[" (getenv "BB_CURRENT_CLIENT") "] %b %f"))

(when window-system
  ;; enable wheelmouse support by default
  (mwheel-install))

;; acm -- April 24th 2008 -- Some key bindings for compilation goodness
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-xc" 'compile)
(global-set-key "\C-cn" 'next-error)
(global-set-key "\C-cp" 'previous-error)

;; (defun bring-up-compilation ()
;;   "Brings up compilation"
;;   (interactive)
;;   (if (and (boundp 'compilation-last-buffer) (not (eq compilation-last-buffer nil)))
;;       (set-window-buffer (selected-window) compilation-last-buffer)
;;     (print "No compile window available"))
;;   )

(defun compilation-next-buffer ()
  "Brings up next compilation buffer, or stays at current if none"
  (interactive)
  (set-window-buffer (selected-window) (compilation-find-buffer 't)))

(global-set-key "\C-xC" 'compilation-next-buffer)

;; make sure ansi sequences are filtered out (thanks to fanatoly)
(defun acm-apply-ansi-color-current-buffer ()
 (ansi-color-apply-on-region (point-min) (point-max) ) )
(add-hook 'compilation-filter-hook 'acm-apply-ansi-color-current-buffer)

;; ACR: auto-scroll is nice
(setq compilation-scroll-output t)

;; ACR: keep the current compile error at top of buf.
(defun next-error-to-top ()
  (save-window-excursion
    (pop-to-buffer next-error-last-buffer nil t)
    (recenter 0)))
(add-hook 'next-error-hook 'next-error-to-top)

;; acm -- April 24th 2008 -- Protect against spurious exit
(global-unset-key "\C-x\C-c")
(defun confirm-exit-emacs ()
  "ask for confirmation before exiting emacs"
  (interactive)
  (if (yes-or-no-p "Are you sure you want to exit? ")
      (save-buffers-kill-emacs)))
(global-set-key "\C-x\C-c" 'confirm-exit-emacs)

;; acm -- April 24th 2008 -- Get some paren highlighting please
(show-paren-mode 1)

;; acm -- April 24th 2008 -- I like column numbers
(column-number-mode 1)

;; acm -- April 24th 2008 -- I also like iswitchb
;; Trying out IDO for a while.
;; (iswitchb-mode 1)

;; acm -- April 26th 2008 -- I hate ~ files
(setq make-backup-files nil)

;; acm -- May 1st 2008 -- enable windmove
(windmove-default-keybindings)

;; acm -- May 20th 2008 -- No toolbar!
(if (> emacs-major-version 20)
    (tool-bar-mode -1))

;; acm -- Dec 11th 2008 -- winner-mode FTW!
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; acm -- Sep 11th 2008 -- flyspell FTW - no more spelling review comments
(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checker." t)
(add-hook 'text-mode-hook 'turn-on-flyspell)
(add-hook 'c++-mode-hook (lambda () (flyspell-prog-mode)))
(setq flyspell-issue-message-flag nil)
(setq flyspell-issue-welcome-flag nil)

;; acm -- May 18th 2009 - don't mess with my frames
(setq pop-up-frames nil)

(defun transparency (value)
  "Sets the transparency of the frame window. 0=transparent/100=opaque"
  (interactive "nTransparency Value 0 - 100 opaque:")
  (set-frame-parameter (selected-frame) 'alpha value))
(transparency 97)

;; TODO(acm): Still want to try this, but it was causing trouble for me
;; Lets try IDO mode
(require 'ido)
(ido-mode 1)
(ido-everywhere 1)
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
(setq ido-default-buffer-method 'selected-window)

;; ACR: setup gdb nicely
(setq gdb-many-windows t)

(savehist-mode 1)

;; ACR: A sort lines replacement that toggles case sensitivity off
;; before doing the sort, then restores it to whatever state it had
;; before.
(defun sort-lines-no-case (reverse beg end)
  "sorts lines without case sensitivity"
  (interactive "P\nr")
  (let ((current-sort-fold-case sort-fold-case))
    (progn (setq sort-fold-case t)
           (sort-lines reverse beg end)
           (setq sort-fold-case current-sort-fold-case))))

;; ACR: stop at the end of the file, not just add newlines
;; forever. Also require that files end with a newline
(setq next-line-add-newlines nil)
(setq require-final-newline t)

;; ACR: use unique buffer names.
(setq uniquify-buffer-name-style 'post-forward)

;; ACR: disable tooltips - they make graphical emacs very laggy over
;; remote X sessions
(tooltip-mode -1)

;; ACR: Nobody likes ~ files
(setq make-backup-files nil)

;; 10gen: More betterer displaying?
(setq redisplay-dont-pause t)
;;(setq redisplay-dont-pause nil)

;; xgen: We call our C++ headers .h files for some reason
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; Turn on red highlighting for characters outside of the 80 char limit
(defun font-lock-width-keyword (width)
  "Return a font-lock style keyword for a string beyond width WIDTH
   that uses 'font-lock-warning-face'."
  `((,(format "^%s\\(.+\\)" (make-string width ?.))
     (1 font-lock-warning-face t))))

(font-lock-add-keywords 'c++-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'c-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'python-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'java-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'perl-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'sh-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'lua-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'ruby-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'javascript-mode (font-lock-width-keyword 100))
(font-lock-add-keywords 'rust-mode (font-lock-width-keyword 100))

(defun font-lock-show-tabs ()
  "Return a font-lock style keyword for tab characters."
  '(("\t" 0 'trailing-whitespace prepend)))

(font-lock-add-keywords 'c++-mode (font-lock-show-tabs))
(font-lock-add-keywords 'c-mode (font-lock-show-tabs))
(font-lock-add-keywords 'python-mode (font-lock-show-tabs))
(font-lock-add-keywords 'java-mode (font-lock-show-tabs))
(font-lock-add-keywords 'perl-mode (font-lock-show-tabs))
(font-lock-add-keywords 'sh-mode (font-lock-show-tabs))
(font-lock-add-keywords 'lua-mode (font-lock-show-tabs))
(font-lock-add-keywords 'ruby-mode (font-lock-show-tabs))
(font-lock-add-keywords 'javascript-mode (font-lock-show-tabs))
(font-lock-add-keywords 'rust-mode (font-lock-show-tabs))

;; Alberto says we do this because of our 100 line length
(setq-default fill-column 95)

;; TODO(acm): There must be a better way to do this.
(add-hook 'c++-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'c-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'python-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'java-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'perl-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'sh-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'lua-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'ruby-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'javascript-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(add-hook 'rust-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#002b36" :foreground "#839496" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 130 :width normal :foundry "apple" :family "Consolas")))))
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
