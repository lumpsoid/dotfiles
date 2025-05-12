;;; init.el --- Modern Emacs configuration without use-package -*- lexical-binding: t -*-

;;; Commentary:
;; This configuration replaces use-package with native Emacs functionality
;; and implements a pipeline pattern for configuration.

;;; Code:

(defun my/utilities ()
  (defun copy-file-path ()
    "Copy the current buffer's file path to kill ring."
    (interactive)
    (if buffer-file-name
        (progn
          (kill-new buffer-file-name)
          (message "Copied: %s" buffer-file-name))
      (message "Buffer is not visiting a file")))
  
  (defun zap-to-non-whitespace ()
    "Delete all whitespace characters from point until the next non-whitespace character."
    (interactive)
    (let ((start (point)))
      (skip-chars-forward " \t\n") ; Skip spaces and tabs and newlines
      (delete-region start (point))))
  (global-set-key (kbd "M-Z") 'zap-to-non-whitespace))

;; Setup autoloads for lazy loading
(defun my/autoload-package (package &rest functions)
  "Set up autoloads for PACKAGE with associated FUNCTIONS."
  (dolist (func functions)
    (autoload func (symbol-name package) nil t)))
1
;; Path configuration based on system type
(defun my/configure-paths ()
  "Configure system-specific paths."
  (setq org-directory
        (cond
         ((eq system-type 'windows-nt) "D:/notes")
         (t "~/Documents/notes")))
    
  ;; Denote directory = org directory
  (setq denote-directory org-directory)
    
  ;; Default notes file
  (setq org-default-notes-file (concat org-directory "/refile.org"))
    
  ;; LSP configuration paths
  (when (eq system-type 'gnu/linux)
    (add-to-list 'exec-path "~/projects/sdk/elixir/elixir-ls")))

;; Load theme - deferred until after init to speed up startup
(defun my/load-theme ()
  "Load the theme after startup."
  (add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
  
  (cond ((member 'modus-operandi-tinted (custom-available-themes))
         (load-theme 'yellow-blue t))
        ((member 'modus-operandi-tinted (custom-available-themes))
         (load-theme 'modus-operandi-tinted))
        
        ((package-installed-p 'color-theme-sanityinc-tomorrow)
         (require 'color-theme-sanityinc-tomorrow)
	     (custom-set-variables '(custom-enabled-themes '(sanityinc-tomorrow-eighties))))
        ((package-installed-p 'dracula-theme)
         (load-theme 'dracula t))))

(defun my/configure-font ()
  ;; Configure font based on system
  (let* ((preferred-font (cond
                          ((eq system-type 'darwin) "Menlo")
                          ((eq system-type 'gnu/linux) "Cascadia Code")
                          ((eq system-type 'windows-nt) "Consolas")
                          (t "Monospace")))
         (font-candidates (list preferred-font "DejaVu Sans Mono" "Source Code Pro" "Ubuntu Mono" "Courier New" "Consolas" "Monospace"))
         (available-font (seq-find (lambda (font) (find-font (font-spec :name font))) font-candidates)))
    (when available-font
      (set-face-attribute 'default nil :font available-font :height 125))))

;; Basic UI settings
(defun my/configure-ui-general ()
  "Configure basic UI settings."
  ;; Disable toolbar
  (tool-bar-mode -1)
  
  ;; Enable line numbers
  (global-display-line-numbers-mode t)
    
  ;; Enable prettify symbols
  (global-prettify-symbols-mode t))

(defun my/configure-ui-graphical ()
  (my/load-theme)
  (my/configure-font))

(defun my/configure-ui-with-frame (frame)
  "Configure UI settings for FRAME.
This function is intended for frame creation hooks."
  (with-selected-frame frame
    ;; Apply general UI configuration
    (my/configure-ui-general)
    
    (when (display-graphic-p)
      ;; Only run UI configuration for graphical frames
      (my/configure-ui-graphical))
    ;; Remove ourselves from the hook after first graphical frame
    (remove-hook 'after-make-frame-functions #'my/configure-ui-with-frame)))

(defun my/setup-ui ()
  "Set up UI configuration based on whether Emacs is running as a daemon."
  (if (daemonp)
      ;; For daemon mode: defer until a frame is created
      (add-hook 'after-make-frame-functions #'my/configure-ui-with-frame)

    ;; For non-daemon mode: configure immediately
    (my/configure-ui-general)
    
    ;; Apply GUI-specific configuration if applicable
    (when (display-graphic-p)
      (my/configure-ui-graphical))))

(defun my/emacs-behavior ()
  "Change default settings for emacs"
  (prefer-coding-system 'utf-8)
  (setq inhibit-startup-message t)
  ;;(setq mouse-wheel-progressive-speed nil)
  )

(defun my/editor ()
  ;; always use spaces for indent
  (setq-default indent-tabs-mode nil
		        ;; first indent then tries to complete
		        tab-always-indent 'complete
		        tab-width 4)

  ;; some old emacs setting default to t
  (setq sentence-end-double-space nil)

  ;; automatic symbol pairing ()
  ;;(require 'electric)
  ;;(electric-pair-mode 1)
  )

;; Package system initialization
(defun my/init-package-system ()
  "Initialize package system with archives and support for lazy loading."
  (require 'package)
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("nongnu" . "https://elpa.nongnu.org/nongnu/") 
                           ("gnu" . "https://elpa.gnu.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")))
  (package-initialize)
  
  ;; Refresh package contents if needed
  (unless package-archive-contents
    (package-refresh-contents))
  
  ;; Define list of required packages
  (setq package-list
        (append
         ;; theme
         '(f
           avy

           ;;dracula-theme
           ;; completion
           vertico
           consult
           orderless
           corfu
           ;; org
		   org-bullets
           ;; programming
           yasnippet         
           ;; lsp
           ;;lsp-mode
           ;;lsp-ui
           ;;lsp-treemacs
           ;;dap-mode 
           ;;lsp-dart
           magit
           denote
		   which-key
           hydra
           markdown-mode)
         (unless (eq system-type 'windows-nt)
           '(telega
             dart-mode
             elixir-mode
             rust-mode
             lua-mode))))
  
  ;; Install packages if not already installed
  (dolist (package package-list)
    (unless (package-installed-p package)
      (package-install package)))
  
  ;; Set up major autoloads
  
  ;;(my/autoload-package 'lsp-mode 'lsp 'lsp-deferred)
  
  (my/autoload-package 'dap-mode 'dap-debug)
  ;;(my/autoload-package 'dart-mode 'dart-mode)
  (my/autoload-package 'elixir-mode 'elixir-mode)
  ;;(my/autoload-package 'lsp-dart 'lsp-dart-flutter-daemon-mode)
  )

;; Personal scripts loading
(defun my/load-personal-scripts ()
  "Load personal scripts from user directory."
  (add-to-list 'load-path "~/.emacs.d/personal/")
  (my/autoload-package 'lump-md 'text-mode-hook 'markdown-mode-hook))

;; Configure completion system
(defun my/configure-completion ()
  "Configure Vertico, Orderless, Consult, and Corfu."
  ;; Minibuffer configurations (built-in)
  (setq enable-recursive-minibuffers t)
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  
  ;; Savehist for persistent history (built-in)
  (savehist-mode 1)
  
  ;; Orderless setup - preload configuration
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles partial-completion))))
  
  ;; Corfu configuration - preload
  (setq corfu-quit-at-boundary 'separator)
  
  ;; Configure Vertico - activate at load time but set up keybindings now
  (require 'vertico)
  (vertico-mode 1)
  
  ;; Vertico key bindings that will work after it's loaded
  (define-key vertico-map (kbd "?") #'minibuffer-completion-help)
  (define-key vertico-map (kbd "M-<RET>") #'minibuffer-force-complete-and-exit)
  (define-key vertico-map (kbd "M-<TAB>") #'minibuffer-complete)
  
  ;; Corfu setup - load at startup for better completion everywhere
  (require 'corfu)
  (define-key corfu-map (kbd "M-SPC") #'corfu-insert-separator)
  (global-corfu-mode 1)
  (corfu-history-mode -1)

  ;; Auto-load corfu when it's first needed
  ;; (autoload 'global-corfu-mode "corfu")
  
  ;; Set up all Consult keybindings (all will autoload Consult when used)
  ;; Standard bindings
  (global-set-key (kbd "C-c M-x") #'consult-mode-command)
  (global-set-key (kbd "C-c h") #'consult-history)
  (global-set-key (kbd "C-c m") #'consult-man)
  (global-set-key (kbd "C-c i") #'consult-info)
  (global-set-key (kbd "C-x M-:") #'consult-complex-command)
  (global-set-key (kbd "C-x b") #'consult-buffer)
  (global-set-key (kbd "C-x 4 b") #'consult-buffer-other-window)
  (global-set-key (kbd "C-x 5 b") #'consult-buffer-other-frame)
  (global-set-key (kbd "C-x t b") #'consult-buffer-other-tab)
  (global-set-key (kbd "C-x r b") #'consult-bookmark)
  (global-set-key (kbd "C-x p b") #'consult-project-buffer)
  (global-set-key (kbd "M-#") #'consult-register-load)
  (global-set-key (kbd "M-'") #'consult-register-store)
  (global-set-key (kbd "C-M-#") #'consult-register)
  (global-set-key (kbd "M-y") #'consult-yank-pop)
  (global-set-key (kbd "M-g e") #'consult-compile-error)
  (global-set-key (kbd "M-g f") #'consult-flymake)
  (global-set-key (kbd "M-g g") #'consult-goto-line)
  (global-set-key (kbd "M-g M-g") #'consult-goto-line)
  (global-set-key (kbd "M-g o") #'consult-outline)
  (global-set-key (kbd "M-g m") #'consult-mark)
  (global-set-key (kbd "M-g k") #'consult-global-mark)
  (global-set-key (kbd "M-g i") #'consult-imenu)
  (global-set-key (kbd "M-g I") #'consult-imenu-multi)
  (global-set-key (kbd "M-s d") #'consult-find)
  (global-set-key (kbd "M-s c") #'consult-locate)
  (global-set-key (kbd "M-s g") #'consult-grep)
  (global-set-key (kbd "M-s G") #'consult-git-grep)
  (global-set-key (kbd "M-s r") #'consult-ripgrep)
  (global-set-key (kbd "M-s l") #'consult-line)
  (global-set-key (kbd "M-s L") #'consult-line-multi)
  (global-set-key (kbd "M-s k") #'consult-keep-lines)
  (global-set-key (kbd "M-s u") #'consult-focus-lines)
  (global-set-key (kbd "M-s e") #'consult-isearch-history)
  
  ;; Isearch integration - configure after isearch loads
  (with-eval-after-load 'isearch
    (define-key isearch-mode-map (kbd "M-e") #'consult-isearch-history)
    (define-key isearch-mode-map (kbd "M-s e") #'consult-isearch-history)
    (define-key isearch-mode-map (kbd "M-s l") #'consult-line)
    (define-key isearch-mode-map (kbd "M-s L") #'consult-line-multi))
  
  ;; Minibuffer integration
  (define-key minibuffer-local-map (kbd "M-s") #'consult-history)
  (define-key minibuffer-local-map (kbd "M-r") #'consult-history))

;; Configure Org mode
(defun my/configure-org ()
  "Configure Org mode settings."
  ;; Set up basic variables - these work even before org is loaded
  (setq org-agenda-files (list org-directory))
  (setq org-todo-keywords '((sequence "TODO" "NEXT" "DONE")))
  
  ;; Configure capture templates
  (setq org-capture-templates
        '(("t" "Todo" entry
           (file+headline org-default-notes-file "Tasks")
           "* TODO %?\n  %i\n  %a")
          ("n" "Note" entry
           (file+headline org-default-notes-file "Notes")
           "* %? :NOTE:\n  %U\n  %i\n  %a")))
  
  ;; Configure refile targets
  (setq org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9)))
  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-outline-path-complete-in-steps nil)
  
  ;; Enable org-indent-mode
  (setq org-indent-mode t)
  
  ;; Setup to run after org is loaded
  (with-eval-after-load 'org
	         ;; Enable org-tempo for structure templates
	         (add-to-list 'org-modules 'org-tempo)
	         
	         ;; Add structure templates
	         (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
	         (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
	         (add-to-list 'org-structure-template-alist '("py" . "src python"))
	         (add-to-list 'org-structure-template-alist '("d" . "src dart"))
	         (add-to-list 'org-structure-template-alist '("elr" . "src elixir")))
  
  ;; Add org-bullets to org-mode-hook to load only when needed
  (autoload 'org-bullets-mode "org-bullets" nil t)
  (add-hook 'org-mode-hook #'org-bullets-mode))

;; Configure Denote
(defun my/configure-denote ()
  "Configure Denote note-taking system."
  (my/autoload-package
   'denote
   'denote
   'denote-link
   'denote-backlinks
   'denote-fontify-links-mode-maybe
   'denote-dired-mode)
  ;; Hooks that will load denote functionality when needed
  (add-hook 'text-mode-hook 'denote-fontify-links-mode-maybe)
  (add-hook 'dired-mode-hook 'denote-dired-mode)
  
  ;; Set configuration variables before loading
  (setq denote-save-buffers nil)
  (setq denote-known-keywords '("emacs" "game" "software" "linux" "log"))
  (setq denote-infer-keywords t)
  (setq denote-sort-keywords nil)
  (setq denote-prompts '(title keywords))
  (setq denote-excluded-directories-regexp nil)
  (setq denote-excluded-keywords-regexp nil)
  (setq denote-rename-confirmations '(rewrite-front-matter modify-file-name))
  (setq denote-date-prompt-use-org-read-date t)
  (setq denote-backlinks-show-context t)
  (setq denote-templates `((game . ,(concat "#+PROPERTY Status Current\n"
                                            "* Some heading"))))
  
  ;; Key bindings - these will autoload denote functions when used
  (global-set-key (kbd "C-c n n") #'denote)
  (global-set-key (kbd "C-c n d") #'denote-sort-dired)
  (global-set-key (kbd "C-c n l") #'denote-link-or-create)
  (global-set-key (kbd "C-c n L") #'denote-add-links)
  (global-set-key (kbd "C-c n b") #'denote-backlinks)
  (global-set-key (kbd "C-c n r") #'denote-rename-file)
  (global-set-key (kbd "C-c n R") #'denote-rename-file-using-front-matter)
  
  ;; Dired mode key bindings
  (with-eval-after-load 'dired
	         (define-key dired-mode-map (kbd "C-c C-d C-i") #'denote-dired-link-marked-notes)
	         (define-key dired-mode-map (kbd "C-c C-d C-r") #'denote-dired-rename-files)
	         (define-key dired-mode-map (kbd "C-c C-d C-k") #'denote-dired-rename-marked-files-with-keywords)
	         (define-key dired-mode-map (kbd "C-c C-d C-R") #'denote-dired-rename-marked-files-using-front-matter))
  
  
  ;; Configuration to apply after denote is loaded
  (with-eval-after-load 'denote
	         ;; Auto-rename buffers
	         (denote-rename-buffer-mode 1)))

(defun my/configure-go-mode ()
  (require 'project)

  (defun project-find-go-module (dir)
    (when-let ((root (locate-dominating-file dir "go.mod")))
      (cons 'go-module root)))

  (cl-defmethod project-root ((project (head go-module)))
    (cdr project))

  (add-hook 'project-find-functions #'project-find-go-module))

(defun my/configure-dart-mode ()
  (with-eval-after-load "dart-mode"
    ;; find dart project root
    (require 'project)
    (defun project-find-dart-module (dir)
      (when-let ((root (locate-dominating-file dir "pubspec.yaml")))
        (cons 'dart-module root)))
    (cl-defmethod project-root ((project (head dart-module)))
      (cdr project))
    (add-hook 'project-find-functions #'project-find-dart-module)
  
    ;; Define function for format current buffer
    (defun dart-format-buffer ()
      "Format the current buffer using dart format."
      (interactive)
      (let ((file-name (buffer-file-name)))
        (if file-name
            (progn
              (message "Formatting %s..." file-name)
              (shell-command (concat "dart format " (shell-quote-argument file-name)))
              (revert-buffer nil t nil)
              (message "Formatting %s...done" file-name))
          (message "Buffer is not visiting a file"))))

    ;; Extract part of the subtree as separate stateless widget
    (defun flutter-extract-widget-to-stateless ()
      "Extract the first Row in a Column as a separate stateless widget."
      (interactive)
      (save-excursion
        ;; Go to the beginning of the current line
        (back-to-indentation)
        ;; Mark the beginning of the widget
        (set-mark (point))
        ;; Find the end of the widget by finding matching parenthesis
        (search-forward "(" nil t)
        ;; back by one char, because `search-forward' will jump over the founded char
        (backward-char)
        (forward-sexp)
        ;; Kill the Row
        (let* ((row-code (buffer-substring (mark) (point)))
               ;; Prompt the user for the class name
               (class-name (read-string "Enter widget class name: ")))
          (kill-region (mark) (point))
          (insert (format "%s())" class-name))
          ;; Go to the end of the file
          (goto-char (point-max))
          ;; Insert a new line and the widget template
          (insert (format "\n\nclass %s extends StatelessWidget {\n" class-name))
          (insert (format "  const %s({super.key});\n\n" class-name))
          (insert "  @override\n")
          (insert "  Widget build(BuildContext context) {\n")
          (insert "    return ")
          ;; Insert the killed Row code with proper indentation
          (insert (replace-regexp-in-string 
                   "^\\s*" "    " 
                   row-code))
          (insert ";\n")
          (insert "  }\n")
          (insert "}\n"))))

    ;; Bind to a key if desired
    (define-key dart-mode-map (kbd "C-c C-e") 'flutter-extract-first-row-widget)

    ;; Keybindings
    (define-key dart-mode-map (kbd "C-c C-o") 'dart-format-buffer))

  ;; Define outline level function
  (defun dart-outline-level ()
    (cond
     ;; Classes are top level
     ((looking-at ".*\\<\\(class\\|enum\\|mixin\\|extension\\|typedef\\)\\>") 1)
     ;; Methods and functions are second level - must start with proper indent and have no prior content
     ((looking-at "^[ \t]*\\([A-Za-z_][A-Za-z0-9_<>]*\\|Future<[^>]*>\\)[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*(.*)[^{]*{") 2)
     ;; Default fallback
     (t 3)))

  ;; Add dart-mode hook
  (add-hook 'dart-mode-hook
            (lambda ()
              (setq-local outline-regexp
                          ;; We need a more precise regex to match only function/method declarations
                          "^[ \t]*\\(\\(class\\|abstract class\\|enum\\|mixin\\|extension\\|typedef\\)[ \t]+[A-Za-z_][A-Za-z0-9_]*\\|\\([A-Za-z_][A-Za-z0-9_<>]*\\|Future<[^>]*>\\)[ \t]+[A-Za-z_][A-Za-z0-9_]*[ \t]*(\\)")
              (setq-local outline-level 'dart-outline-level)
              (outline-minor-mode 1))))

(defun my/treesiter ()
  (add-to-list 'treesit-language-source-alist '(go "https://github.com/tree-sitter/tree-sitter-go"))
  (add-to-list 'treesit-language-source-alist '(gomod "https://github.com/camdencheek/tree-sitter-go-mod"))
  (add-to-list 'treesit-language-source-alist '(dart "https://github.com/UserNobody14/tree-sitter-dart"))
  (add-to-list 'treesit-language-source-alist '(elixir "https://github.com/elixir-lang/tree-sitter-elixir")))

(defun my/configure-lspce ()
  ;; Load the lspce package from the specified path
  (add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp/lspce"))
  ;;(require 'lspce)
  (autoload 'lspce-mode "lspce" "LSP client for Emacs" t)

  ;; Configuration settings
  (setq lspce-send-changes-idle-time 0.2)
  (setq lspce-show-log-level-in-modeline t) ;; show log level in mode line

  (defun my/lspce-start ()
    ;; Enable lspce-mode
    (lspce-mode)
    ;; Disable backup files
    (setq-local make-backup-files nil))
  
  ;; enable lspce in particular buffers
  (add-hook 'rust-mode-hook 'my/lspce-start)
  (add-hook 'dart-mode-hook 'my/lspce-start)
  (add-hook 'elixir-mode-hook 'my/lspce-start)
  
  ;; Define keybindings for lspce-mode-map after the package is loaded
  (with-eval-after-load 'lspce
    ;; You should call this first if you want lspce to write logs
    (lspce-set-log-file "/tmp/lspce.log")

    ;; By default, lspce will not write log out to anywhere. 
    ;; To enable logging, you can add the following line
    (lspce-enable-logging)
    ;; You can enable/disable logging on the fly by calling `lspce-enable-logging' or `lspce-disable-logging'.
    
    (define-key lspce-mode-map (kbd "C-c l h") 'lspce-help-at-point)
    (define-key lspce-mode-map (kbd "C-c l r") 'lspce-rename)
    (define-key lspce-mode-map (kbd "C-c l a") 'lspce-code-actions)
    (define-key lspce-mode-map (kbd "C-c l s") 'lspce-shutdown-server))

  ;; https://github.com/dart-lang/sdk/tree/main/pkg/analysis_server/tool/lsp_spec
  (defun lspce-dart-initializationOptions ()
    (let ((options (make-hash-table :test #'equal)))
      ;; Core features
      (lspce--add-option "onlyAnalyzeProjectsWithOpenFiles" :json-false options)
      (lspce--add-option "suggestFromUnimportedLibraries" t options)
      (lspce--add-option "closingLabels" t options)
      (lspce--add-option "outline" t options)
      (lspce--add-option "flutterOutline" t options)
      (lspce--add-option "allowOpenUri" t options)
      
      ;; Client workspace configuration
      (let ((dart-config (make-hash-table :test #'equal)))
        (lspce--add-option "analysisExcludedFolders" [] dart-config)
        (lspce--add-option "enableSdkFormatter" t dart-config)
        (lspce--add-option "lineLength" 80 dart-config)
        (lspce--add-option "completeFunctionCalls" t dart-config)
        (lspce--add-option "showTodos" t dart-config)
        (lspce--add-option "renameFilesWithClasses" "prompt" dart-config)
        (lspce--add-option "enableSnippets" t dart-config)
        (lspce--add-option "updateImportsOnRename" t dart-config)
        (lspce--add-option "documentation" "full" dart-config)
        (lspce--add-option "includeDependenciesInWorkspaceSymbols" t dart-config)
        (puthash "dart" dart-config options))
      
      options))

  (defun lspce-elixir-initializationOptions ()
    (let ((options (make-hash-table :test #'equal)))
      ;; ElixirLS specific options
      (lspce--add-option "autoBuild" t options)
      (lspce--add-option "dialyzerEnabled" t options)
      ;;(lspce--add-option "incrementalDialyzer" t options)
      (lspce--add-option "fetchDeps" t options)
      (lspce--add-option "suggestSpecs" t options)
      (lspce--add-option "autoInsertRequiredAlias" t options)
      (lspce--add-option "signatureAfterComplete" t options)
      (lspce--add-option "enableTestLenses" t options)
      
      ;; Set Mix environment if needed
      ;;(lspce--add-option "mixEnv" "dev" options)
      
      ;; Empty array for additional watched extensions
      (lspce--add-option "additionalWatchedExtensions" [] options)
      
      ;; Dialyzer format and warning options
      (lspce--add-option "dialyzerFormat" "dialyxir" options)
      ;;(lspce--add-option "dialyzerWarnOpts" (make-hash-table :test #'equal) options)
      
      options))

  ;; modify `lspce-server-programs' to add or change a lsp server, see document
  ;; of `lspce-lsp-type-function' to understand how to get buffer's lsp type.
  ;; Bellow is what I use
  ;; first argument from the `lspce--lsp-type-default' eval
  ;; check that `lspce--project-root' is not nil
  (setq lspce-server-programs `(("rust"   "rust-analyzer" "" lspce-ra-initializationOptions)
                                ("dart"   "dart" "language-server --client-id emacs.lspce --client-version 1.24.3" lspce-dart-initializationOptions)
                                ("go"     "gopls" "" nil)
                                ("elixir" ,(expand-file-name "~/projects/sdk/elixir/elixir-ls/language_server.sh") "" lspce-elixir-initializationOptions)
                                ("nix"    "nil" "" nil))))

;; Configure LSP mode
(defun my/configure-lsp ()
  "Configure LSP mode and related packages."
  ;; Set up basic LSP configuration variables before loading
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-enable-which-key-integration t)
  (setq lsp-idle-delay 0.500)
  (setq lsp-completion-provider :none)
  (setq lsp-eldoc-enable-hover t)

  ;; Add LSP hooks for various programming modes
  ;; These will load LSP only when the mode is activated
  (add-hook 'python-mode-hook #'lsp-deferred)
  (add-hook 'c++-mode-hook #'lsp-deferred)
  (add-hook 'elixir-mode-hook #'lsp-deferred)
  (add-hook 'golang-mode-hook #'lsp-deferred)
  (add-hook 'js-mode-hook #'lsp-deferred)
  ;;(add-hook 'dart-mode-hook #'lsp-deferred)
  
  ;; Fix lsp-mode overriding completion-category-defaults after it loads
  (with-eval-after-load 'lsp-mode
	         (add-hook 'lsp-completion-mode-hook
		               (lambda ()
			             (setq-local completion-category-defaults
				                     (assoc-delete-all 'lsp-capf completion-category-defaults)))))
  
  ;; Configure lsp-ui after it loads
  (with-eval-after-load 'lsp-ui
	         (setq lsp-ui-sideline-enable t)
	         (setq lsp-ui-sideline-show-diagnostics t)
	         (setq lsp-ui-sideline-show-hover t)
	         (setq lsp-ui-doc-enable t)
	         (setq lsp-ui-doc-position 'at-point)
	         (setq lsp-ui-doc-show-with-mouse nil)
	         (setq lsp-ui-peek-enable t))
  
  ;; Configure lsp-treemacs after it loads
  (with-eval-after-load 'lsp-treemacs
	         (lsp-treemacs-sync-mode 1))
  
  ;; Configure dap-mode for debugging
  (with-eval-after-load 'dap-mode
	         (dap-auto-configure-mode))
  
  ;; LSP key bindings - these will autoload the needed functions when keys are pressed
  (global-set-key (kbd "C-c l ds") #'lsp-ui-doc-show)
  (global-set-key (kbd "C-c l el") #'lsp-treemacs-errors-list)
  (global-set-key (kbd "C-c l ts") #'lsp-treemacs-symbols)
  (global-set-key (kbd "C-c l rr") #'lsp-rename))

;; Configure Magit
(defun my/configure-magit ()
  "Configure Magit."
  ;; No pre-loading needed - all magit functions are autoloaded in my/init-package-system
  ;; Optional: Add any magit configuration to execute after it's loaded
  ;;(with-eval-after-load 'magit
  ;; Any magit specific configuration would go here
  ;;  )
  (my/autoload-package 'magit 'magit-status 'magit-dispatch 'magit-file-dispatch))

;; Configure which-key
(defun my/configure-which-key ()
  "Configure which-key."
  ;; Autoload which-key-mode
  ;;(autoload 'which-key-mode "which-key" nil t)
  ;; Enable which-key-mode at startup - it's lightweight enough to not need deferral
  (which-key-mode 1))

;; Configure avy
(defun my/configure-avy ()
  "Configure avy for better navigation."
  ;; Basic configuration for avy (works before loading)
  (setq avy-timeout-seconds 0.4)
  (setq avy-keys '(?q ?e ?r ?u ?o ?p
                      ?a ?s ?d ?f ?g ?h ?j
                      ?l ?' ?c ?v ?b
                      ?n ?, ?/))
  
  ;; Key binding that will autoload avy when used
  (global-set-key (kbd "M-j") #'avy-goto-char-timer)
  
  ;; Autoload the avy functions
  (autoload 'avy-goto-char-timer "avy" nil t)
  
  ;; Further configuration to apply after avy is loaded
  (with-eval-after-load 'avy
	;; Show dispatch help
	(defun avy-show-dispatch-help ()  
	  (let* ((len (length "avy-action-"))
		     (fw (frame-width))
		     (raw-strings (mapcar
				           (lambda (x)
				             (format "%2s: %-19s"
					                 (propertize
					                  (char-to-string (car x))
					                  'face 'aw-key-face)
					                 (substring (symbol-name (cdr x)) len)))
				           avy-dispatch-alist))
		     (max-len (1+ (apply #'max (mapcar #'length raw-strings))))
		     (strings-len (length raw-strings))
		     (per-row (floor fw max-len))
		     display-strings)
		(cl-loop for string in raw-strings
			     for N from 1 to strings-len do
			     (push (concat string " ") display-strings)
			     (when (= (mod N per-row) 0) (push "\n" display-strings)))
		(message "%s" (apply #'concat (nreverse display-strings)))))
	         
	;; Generic action functions
	(defun avy-generic-command-action (pt action-f)
	  "Executes action-f at point and stays"
	  (save-excursion
		(goto-char pt)
		(funcall action-f))
	  (select-window
	   (cdr (ring-ref avy-ring 0)))
	  t)
	         
	(defun avy-generic-command-action-no-stay (pt action-f)
	  "Executes action-f at point and returns to original position"
	  (goto-char pt)
	  (funcall action-f)
	  t)

	;; Define a hydra with actions to perform at point
	(defhydra hydra-avy-actions (:color blue :hint nil)
	  "
^Actions at point^
--------------------------------------------------------------
_w_: copy word       _l_: copy line       _s_: copy sexp
_k_: kill word       _j_: kill line       _d_: kill sexp
_y_: yank here       _m_: set mark        _t_: teleport
_q_: quit
"
	  ("w" (lambda () (interactive) (kill-new (thing-at-point 'word))))
	  ("l" (lambda () (interactive) (kill-new (thing-at-point 'line))))
	  ("s" (lambda () (interactive) (kill-new (thing-at-point 'sexp))))
	  ("k" (lambda () (interactive)
		     (kill-word 1)
		     (avy-pop-mark)))
	  ("j" kill-line)
	  ("d" kill-sexp)
	  ("y" yank)
	  ("m" set-mark-command nil)
	  ("t" (lambda () (interactive) 
		     (let ((orig (point)))
			   (save-excursion
			     (call-interactively 'avy-goto-char-timer)
			     (setq target (point)))
			   (delete-region orig (1+ orig))
			   (goto-char target)
			   (yank))))
	  ("q" nil :color blue))
	         
	;; Custom avy action to show hydra
	(defun avy-action-show-hydra (pt)
	  "Show hydra at PT."
	  (goto-char pt)
	  (hydra-avy-actions/body)
	  t)
	         
	;; Add the action to avy-dispatch-alist
	(setq avy-dispatch-alist
		  (append avy-dispatch-alist
			      '((?\C-h . avy-action-show-hydra))))

    ;; Define a hydra specifically for LSP actions
    (defhydra hydra-avy-lsp-actions (:color blue :hint nil)
      "
^LSP Actions at Point^
--------------------------------------------------------------
*d*: Find definition      *r*: Find references      *t*: Find type definition
*R*: Rename               *h*: Show documentation   *a*: Code actions
*q*: quit
"
      ("d" xref-find-definitions)
      ("r" xref-find-references)
      ("t" xref-find-type-definition)
      ("R" lspce-rename)
      ("a" lspce-code-actions)
      ("h" lspce-help-at-point)
      ("q" nil :color blue))

	;; Custom avy action to show LSP hydra
	(defun avy-action-lsp-hydra (pt)
	  "Show LSP action hydra at PT."
	  (goto-char pt)
	  (hydra-avy-lsp-actions/body)
	  t)

	;; Add the LSP action to avy-dispatch-alist
	(setq avy-dispatch-alist
		  (append avy-dispatch-alist
			      '((?\C-l . avy-action-lsp-hydra))))
	         
	;; Define key for region killing with avy
	;; (defun avy-kill-region ()
	;;   "Kill region between point and avy point."
	;;   (interactive)
	;;   (let ((p1 (point)))
	;; 	 (when (call-interactively 'avy-goto-char-timer)
	;; 	   (kill-region p1 (point)))))
	         
	;; Kill text actions
	(defun avy-action-kill-whole-line (pt)
	  (avy-generic-command-action pt #'kill-whole-line))
	         
	(setf (alist-get ?k avy-dispatch-alist) 'avy-action-kill-stay
		  (alist-get ?K avy-dispatch-alist) 'avy-action-kill-whole-line)
    
	;; Copy text actions
    (defun avy-action-copy-whole-line (pt)
      (avy-generic-command-action 
       pt 
       (lambda ()
         (let ((start (progn (back-to-indentation)
                             (point)))
               (end (progn (end-of-line)
                           (skip-syntax-backward " " (line-beginning-position))
                           (point))))
           (copy-region-as-kill start end)))))
	         
	(setf (alist-get ?w avy-dispatch-alist) 'avy-action-copy
		  (alist-get ?W avy-dispatch-alist) 'avy-action-copy-whole-line)
	         
	;; Yank text actions
	(defun avy-action-yank-whole-line (pt)
	  (avy-action-copy-whole-line pt)
	  (save-excursion (yank))
	  t)
	         
	(setf (alist-get ?y avy-dispatch-alist) 'avy-action-yank
		  (alist-get ?Y avy-dispatch-alist) 'avy-action-yank-whole-line)
	         
	;; Transpose/Move text actions
	;; (defun avy-action-teleport-whole-line (pt)
	;;   (avy-action-kill-whole-line pt)
	;;   (save-excursion (yank)) t)

    (defun avy-action-teleport-whole-line (pt)
      (save-excursion
        (goto-char pt)
        (let ((start (progn (back-to-indentation)
                            (point)))
              (end (progn (end-of-line)
                          (skip-syntax-backward " " (line-beginning-position))
                          ;; We don't need backward-prefix-chars here since we're 
                          ;; going backward from the end
                          (point))))
          (kill-region start end)))
      (save-excursion (yank)) t)

    (defun avy-action-teleport-region (pt)
      "Teleport a region starting at PT to the point where avy was initiated.
After selecting the starting point with avy and choosing this action,
you'll be prompted to select the end point of the region."
      (interactive)
      ;; PT is already the first point selected by avy
      (let* ((start-pt pt)
             ;; Get second point with another avy call
             (end-pt nil))
    
        ;; Use avy-goto-char-2 to get the second point
        (save-excursion
          (call-interactively 'avy-goto-char-2)
          (setq end-pt (point)))
            
        ;; Ensure we have both points
        (when (and start-pt end-pt)
          ;; Make sure start is before end
          (when (> start-pt end-pt)
            (let ((temp start-pt))
              (setq start-pt end-pt)
              (setq end-pt temp)))

          ;; Kill the region
          (kill-region start-pt end-pt)

          (yank)))
      t)
        
	(setf (alist-get ?t avy-dispatch-alist) 'avy-action-teleport
		  (alist-get ?T avy-dispatch-alist) 'avy-action-teleport-whole-line
          (alist-get ?\C-t avy-dispatch-alist) 'avy-action-teleport-region)
	         
	;; Mark text actions              )
	(defun avy-action-mark-to-char (pt)
	  (activate-mark)
	  (goto-char pt))
	         
	(setf (alist-get ?  avy-dispatch-alist) 'avy-action-mark-to-char)
	         
	;; Flyspell words
	(defun avy-action-flyspell (pt)
	  (avy-generic-command-action pt (lambda()
					                   (when (require 'flyspell nil t)
					                     (flyspell-auto-correct-word)))))
	         
	;; Bind to semicolon (flyspell uses C-;)
	(setf (alist-get ?\; avy-dispatch-alist) 'avy-action-flyspell)
             
	;; LSP actions
	(defun avy-action-lsp-help (pt)
	  (avy-generic-command-action pt #'lsp-describe-thing-at-point))
	;;(setf (alist-get ?\C-h avy-dispatch-alist) 'avy-action-lsp-help)
	         
	(defun avy-action-lsp-rename (pt)
	  (avy-generic-command-action pt #'lsp-rename))
	(setf (alist-get ?\C-r avy-dispatch-alist) 'avy-action-lsp-rename)))

;; Set up additional global keybindings
(defun my/configure-global-keys ()
  "Configure global keybindings."
  
  ;; Set up keybindings
  (global-set-key (kbd "C-c C-d") #'duplicate-line)
  (global-set-key (kbd "C-c k r") #'avy-kill-region))

;; Startup performance measurement
(defun my/measure-startup ()
  "Display startup time and garbage collection count."
  (add-hook 'emacs-startup-hook
            (lambda()
              (message "*** Emacs loaded in %s with %d garbage collections."
                       (format "%.2f seconds"
                               (float-time
				                (time-subtract after-init-time before-init-time)))
                       gcs-done))))

;; Initial file to speed up loading
(defun my/create-custom-file ()
  "Create a separate custom file to avoid cluttering init.el."
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (unless (file-exists-p custom-file)
    (with-temp-file custom-file
      (insert ";;; custom.el --- auto-generated custom variables file\n\n")))
  (load custom-file 'noerror 'nomessage))

(defun my/telega ()
  (unless (eq system-type 'windows-nt)
    (setq telega-directory
	      (concat (or (getenv "XDG_DATA_HOME")
		              (expand-file-name "~/.local/share"))
		          "/telega/"))
    ;; Configure image and emoji settings
    (setq telega-use-images t)
    (setq telega-emoji-use-images nil)
    (setq telega-user-show-avatars nil)
    (setq telega-chat-show-avatars nil)
    (setq telega-emoji-font-family "Noto Color Emoji")
    (add-hook 'telega-load-hook 'telega-notifications-mode)
    
    ;; Example online status function - customize as needed
    ;;(setq telega-online-status-function 
    ;;      (lambda (user)
    ;;        (not (eq (telega-user--seen user) 'offline))))
    (defun my/telega-layout ()
      "Set up a custom layout for Telega with three windows:
   1. Telega root buffer on the left
   2. Telega notification history on the top right
   3. Another Telega root buffer on the bottom right"
      (interactive)
      ;; Delete all windows and start fresh
      (delete-other-windows)
  
      ;; Split frame into left and right sections
      (split-window-right)
  
      ;; open telega root
      (telega)
  
      ;; open notification history, it will open in the second window
      (telega-notifications-history))
    
    ;; Add the setup function to telega-chat-mode-hook
    (with-eval-after-load 'telega
      (require 'telega-completion-corfu)
      (define-key telega-chat-mode-map (kbd "C-c @") #'my/telega-complete-username)
      (add-hook 'telega-chat-mode-hook #'my/telega-setup-completion))))

;; The main configuration pipeline
(defun my/init-emacs ()
  "Initialize Emacs with the pipeline of configurations."
  ;; Set high GC threshold during startup
  (setq gc-cons-threshold most-positive-fixnum
        gc-cons-percentage 0.6)
  
  ;; Create custom file
  (my/create-custom-file)
  
  ;; Initialization and UI setup
  (my/init-package-system)
  (my/configure-paths)
  (my/emacs-behavior)
  (my/editor)
  (my/setup-ui)
  (my/load-personal-scripts)
  (my/utilities)
  
  ;; General features and modes
  (my/configure-completion)
  (my/configure-org)
  (my/configure-denote)
  (my/configure-magit)
  (my/configure-which-key)

  ;; applications
  (my/telega)
  
  ;; Development environment
  ;;(my/configure-lsp)
  (my/configure-lspce)
  (my/configure-dart-mode)
  (my/configure-go-mode)
  (my/configure-avy)
  
  ;; Final configurations
  (my/configure-global-keys)
  (my/measure-startup)
  
  ;; Reset GC threshold to reasonable values after startup
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq gc-cons-threshold (* 100 1024 1024)
                    gc-cons-percentage 0.1
                    read-process-output-max (* 1024 1024))
              
              ;; Run GC once after startup
              (garbage-collect))))

;; Run the initialization pipeline
(my/init-emacs)

(provide 'init)
;;; init.el ends here
