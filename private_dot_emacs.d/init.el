;; Setup package paths
(let ((default-directory  "/home/dknite/.emacs.d/pkgs/"))
  (if (file-directory-p default-directory)
    (normal-top-level-add-subdirs-to-load-path)))


(require 'base16-theme)
(load-theme 'base16-gruvbox-dark-hard t)


(setq-default
 indent-tabs-mode nil
 tab-stop-list (number-sequence 2 200 2)
 tab-width 2
 indent-line-function 'insert-tab)
;; (electric-indent-mode -1)

;; Main fonts
(set-face-attribute 'default nil
  :font "Iosevka Curly"
  :height 135
  :weight 'normal)
(set-face-attribute 'variable-pitch nil
  :font "Noto Sans"
  :height 150
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "Iosevka Curly"
  :height 135
  :weight 'normal)

;; Make comments italics
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
		    :slant 'italic)

(add-to-list 'default-frame-alist '(font . "Iosevka Curly"))

;; Nerd Icons
(require 'nerd-icons)
(setq nerd-icons-fornt-family "Symbols Nerd Font")

;; Disable stuff I don't like
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 10)

;; Line numbers
(global-display-line-numbers-mode 1)
(global-visual-line-mode t)
(dolist (mode '(org-mode-hook
                term-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq backup-directory-alist '((".*" . "~/.emacsdid")))



;; Evil and related stuff
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)
(require 'evil)
(evil-mode 1)

(when (require 'evil-collection nil t)
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(require 'evil-escape)

(require 'fzf)
(setq fzf/executable "fzf"
      fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
      fzf/git-grep-args "-i --line-number %s"
      fzf/grep-command "rg --no-heading -nH"
      fzf/position-bottom t
      fzf/window-height 15)


;; General keybindings
(require 'general)
(general-evil-setup)

(general-define-key
    :states '(normal visual)
    "C-u" 'evil-scroll-up
    "C-b" 'neotree-toggle
    "H" 'back-to-indentation
    "L" 'move-end-of-line
    "M-x" 'counsel-M-x
    "C-s" 'swiper)

(general-define-key
 :keymaps 'eglot-mode-map
    "M-j" 'counsel-imenu
    "M-/" 'xref-find-definitions
    "M-?" 'xref-find-references
    "C-c C-c h" 'eldoc
    "C-c C-c l" 'flymake-show-buffer-diagnostics
    "C-c C-c a" 'eglot-code-actions
    "C-c C-c r" 'eglot-rename
    "C-c C-c q" 'eglot-reconnect
    "C-c C-c Q" 'eglot-shutdown
    "C-c C-c C-f" 'eglot-format)

(general-define-key
 :keymaps 'flymake-mode-map
 "M-n" 'flymake-goto-next-error
 "M-p" 'flymake-goto-prev-error)

(general-define-key
    :states '(insert visual)
    "C-k" 'evil-escape)

(general-create-definer dknite/leader-keys
  :states '(normal insert visual emacs)
  :keymaps 'override
  :prefix "SPC" ;; set leader
  :global-prefix "M-SPC") ;; access leader in insert mode

(dknite/leader-keys
  "s s" '(save-buffer :wk "Save buffer")
  "s f" '(counsel-find-file :wk "Find file in directory")
  "s d f" '(counsel-fzf :wk "Find file in directory with fzf")
  "s g f" '(counsel-git :wk "Find file in git directory")
  "s r" '(counsel-grep :wk "Ripgrep in directory")
  "s g r" '(counsel-git-grep :wk "Ripgrep in git directory")
  "s b" '(counsel-buffer-or-recentf :wk "Switch buffer"))

(dknite/leader-keys
  "." '(find-file :wk "Find file")
  "f r" '(counsel-recentf :wk "Find recent files")
  "f c" '((lambda () (interactive) (find-file "~/.emacs.d/init.el")) :wk "Edit emacs config"))

(dknite/leader-keys
  "e" '(:ignore t :wk "Evaluate")
  "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
  "e d" '(eval-defun :wk "Evaluate defun containing or after point")
  "e e" '(eval-expression :wk "Evaluate elisp expression")
  "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
  "e r" '(eval-region :wk "Evaluate elisp in region"))

(dknite/leader-keys
  "h" '(:ignore t :wk "Help")
  "h f" '(describe-function :wk "Describe function")
  "h v" '(describe-variable :wk "Describe variable")
  "h r r" '((lambda () (interactive) 
              (load-file "~/.emacs.d/init.el")
              (load-file "~/.emacs.d/init.el")) :wk "Reload emacs config"))



;; GUI Tweaks
(require 'rainbow-delimiters)
(add-hook 'org-mode-hook 'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(require 'hl-todo)
(add-hook 'org-mode-hook 'hl-todo-mode)
(add-hook 'prog-mode-hook 'hl-todo-mode)
(setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        '(("TODO"   warning  bold)
          ("FIXME"  error bold)))

(require 'which-key)
(which-key-mode 1)
(setq which-key-side-window-location 'bottom
    which-key-sort-order #'which-key-key-order-alpha
    which-key-sort-uppercase-first nil
    which-key-add-column-padding 1
    which-key-max-display-columns nil
    which-key-min-display-lines 6
    which-key-side-window-slot -10
    which-key-side-window-max-height 0.25
    which-key-idle-delay 0.8
    which-key-max-description-length 25
    which-key-allow-imprecise-window-fit t
    which-key-separator " -> ")

(when (display-graphic-p)
  (require 'all-the-icons)
  (require 'all-the-icons-dired)
  (setq all-the-icons-dired-monochrome nil)
  (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))


;; Don't pass the --dired option to ls on Mac
(setq dired-use-ls-dired nil)

(require 'doom-modeline)
(doom-modeline-mode 1)
(setq doom-modeline-height 30
      doom-modeline-bar-width 5
      doom-modeline-persp-name t
      doom-modeline-persp-icon t)

(require 'dashboard)
(add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
(add-hook 'elpaca-after-init-hook #'dashboard-initialize)
(dashboard-setup-startup-hook)
(setq dashboard-banner-logo-title "Enter the Emacs")
(setq dashboard-startup-banner 'logo)
(setq dashboard-center-content t)
(setq dashboard-show-shortcuts nil)
(setq dashboard-display-icons-p t)
(setq dashboard-icon-type 'nerd-icons)
;; (setq dashboard-set-heading-icons t)
;; (setq dashboard-set-file-icons t)
(setq dashboard-items '((recents . 5) 
                        (projects . 5)))

(require 'neotree)
(setq neo-theme
 (if (display-graphic-p) 'icons 'arrow))


(require 'magit)
(with-eval-after-load 'info
  (info-initialize)
  (add-to-list 'Info-directory-list
               "/Users/dknite/pkgs/magit/docs"))

(require 'sudo-edit)
(dknite/leader-keys
  "fu" '(sudo-edit-find-file :wk "Sudo find file")
  "fU" '(sudo-edit :wk "Sudo edit file"))

(require 'envrc)
(add-hook 'after-init-hook 'envrc-global-mode)

(require 'company)

(require 'ivy)
(require 'counsel)
(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

;; Rust stuff
(require 'rustic)
(setq rustic-format-on-save t)
(setq rustic-lsp-client 'eglot)
;; (add-hook 'eglot-managed-mode-hook (lambda () (flymake-mode -1)))
(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (eldoc-mode -1)
            (company-mode 1)))

;; OCaml
(require 'tuareg)

;; Other languages
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(add-hook 'tuareg-mode-hook 'eglot-ensure)
