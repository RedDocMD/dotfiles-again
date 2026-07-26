;; Setup elpaca
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

(elpaca
    (cond-let
      :host github
      :repo "tarsius/cond-let"
      :ref "21b9e9835756ff5cd1acb971cf9eb56fff671c8b"))

(elpaca-process-queues)
(elpaca-wait)

(use-package compat
  :ensure t
  :after cond-let)

(use-package transient
  :ensure t
  :after compat)

(use-package magit
  :ensure t
  :after transient
  :custom
  (setq magit-git-executable "/usr/bin/git"))

(use-package base16-theme
  :ensure t
  :config
  (load-theme 'base16-gruvbox-dark-hard t))

;; Indentation
(setq-default
 indent-tabs-mode nil
 tab-stop-list (number-sequence 2 200 2)
 tab-width 2
 indent-line-function 'insert-tab)
;; (electric-indent-mode -1)

(setq ring-bell-function (lambda () ()))

;; Main fonts
(set-face-attribute 'default nil
  :font "FiraCode Nerd Font"
  :height 135
  :weight 'normal)
(set-face-attribute 'variable-pitch nil
  :font "Noto Sans"
  :height 150
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "FiraCode Nerd Font"
  :height 135
  :weight 'normal)

;; Make comments italics
(set-fringe-mode 10)

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
(setq display-line-numbers 'relative)

(setq backup-directory-alist '((".*" . "~/.emacsdid")))

(use-package fzf
  :ensure t
  :config
  (setq fzf/executable "fzf"
        fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/git-grep-args "-i --line-number %s"
        fzf/grep-command "rg --no-heading -nH"
        fzf/position-bottom t
        fzf/window-height 15))

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package evil-escape
   :after evil
   :ensure t
   :config
   (evil-escape-mode))


(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode 1))

(defun meain/evil-yank-advice (orig-fn beg end &rest args)
  (pulse-momentary-highlight-region beg end)
  (apply orig-fn beg end args))
(advice-add 'evil-yank :around 'meain/evil-yank-advice)

(use-package general
  :after evil
  :ensure t
  :config
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
      :states '(insert visual)
      "C-k" 'evil-escape)

  (general-create-definer dknite/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (dknite/leader-keys
    "s s" '(save-buffer :wk "Save buffer")
    "s f" '(counsel-fzf :wk "Find file in directory")
    "s g f" '(counsel-git :wk "Find file in git directory")
    "s r" '(counsel-rg :wk "Ripgrep in directory")
    "s g r" '(counsel-git-grep :wk "Ripgrep in git directory")
    "s b" '(counsel-buffer-or-recentf :wk "Switch buffer")
    "s h" '(counsel-tramp :wk "Counsel for Tramp"))

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
                (load-file "~/.emacs.d/init.el")) :wk "Reload emacs config")))


(use-package rainbow-delimiters
  :ensure t
  :hook
  (org-mode . rainbow-delimiters-mode)
  (prog-mode . rainbow-delimiters-mode))

(use-package hl-todo
  :ensure t
  :config
  (setq hl-todo-highlight-punctuation ":"
          hl-todo-keyword-faces
          '(("TODO"   warning  bold)
            ("FIXME"  error bold)))
  :hook
  (org-mode . hl-todo-mode)
  (prog-mode . hl-todo-mode))

(use-package which-key
  :ensure t
  :config
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
      which-key-separator " -> "))

(use-package doom-modeline
  :ensure t
  :config
  (doom-modeline-mode 1)
  (setq doom-modeline-height 30
        doom-modeline-bar-width 5
        doom-modeline-persp-name t
        doom-modeline-persp-icon t))

(use-package dashboard
  :ensure t
  :config
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
  :hook
  (elpaca-after-init . dashboard-insert-startupify-lists)
  (elpaca-after-init . dashboard-initialize))

(use-package neotree
  :ensure t
  :config
  (setq neo-theme 'icons))

(use-package company :ensure t)

(use-package ivy
  :ensure t
  :config
  (ivy-mode)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t))
(use-package counsel :ensure t)
(use-package counsel-tramp :ensure t)

(use-package lsp-haskell
  :ensure t
  :config
  (setq lsp-haskell-formatting-provider "stylish-haskell"))

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((c-mode . lsp)
         (c++-mode . lsp)
         (haskell-mode . lsp)
         (rust-mode . lsp)
         (tuareg-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :bind-keymap ("C-c l" . lsp-command-map))

(use-package lsp-ui 
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-show-with-cursor nil))
(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol)

;; Lsp Mode, Language support
(use-package rustic
  :ensure t
  :config
  (setq rustic-lsp-setup-p nil))
;; Haskell mode
(use-package haskell-mode :ensure t)
(use-package tuareg :ensure t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(magit)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
