;;; yellow-blue-theme.el --- A theme with yellow text on blue background

;; Copyright (C) 2025
;; Author:
;; Version: 1.0
;; Keywords: faces
;; Package-Requires: ((emacs "24.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; A theme featuring yellow text on blue background with proper syntax highlighting
;; for programming languages.

;;; Code:

(deftheme yellow-blue
  "Theme with yellow text on blue background with syntax highlighting for programming.")

(let ((class '((class color) (min-colors 89)))
      ;; Base colors
      (yb-yellow           "#ffee99")        ; Main text color - slightly off-yellow for better readability
      (yb-bright-yellow    "#ffff00")        ; Brighter yellow for highlights
      (yb-gold             "#ffd700")        ; Gold for keywords
      (yb-orange           "#ffa500")        ; Orange for constants
      (yb-amber            "#ffbf00")        ; Amber for parameters
      (yb-light-yellow     "#fffacd")        ; Light yellow for docstrings
      (yb-blue-bg          "#000066")        ; Main background - deep blue
      (yb-dark-blue-bg     "#000044")        ; Darker blue for contrast
      (yb-lighter-blue-bg  "#000088")        ; Lighter blue for selection
      (yb-very-light-blue  "#0000aa")        ; Very light blue for highlights
      (yb-cyan             "#00ffff")        ; Cyan for strings
      (yb-green            "#00ff00")        ; Green for success
      (yb-red              "#ff4500")        ; Red for errors/warnings
      (yb-magenta          "#ff00ff")        ; Magenta for diff
      (yb-white            "#ffffff")        ; Pure white
      (yb-light-gray       "#dddddd")        ; Light gray
      (yb-gray             "#888888")        ; Gray
      (yb-dark-gray        "#444444"))       ; Dark gray

  (custom-theme-set-faces
   'yellow-blue
   
   ;; Basic faces
   `(default ((,class (:foreground ,yb-yellow :background ,yb-blue-bg))))
   `(cursor ((,class (:background ,yb-bright-yellow))))
   `(fringe ((,class (:background ,yb-dark-blue-bg))))
   `(highlight ((,class (:background ,yb-very-light-blue))))
   `(region ((,class (:background ,yb-lighter-blue-bg))))
   `(vertical-border ((,class (:foreground ,yb-dark-gray))))
   `(minibuffer-prompt ((,class (:foreground ,yb-bright-yellow :weight bold))))
   `(error ((,class (:foreground ,yb-red :weight bold))))
   `(warning ((,class (:foreground ,yb-orange :weight bold))))
   `(success ((,class (:foreground ,yb-green :weight bold))))
   
   ;; Font lock faces
   `(font-lock-builtin-face ((,class (:foreground ,yb-gold))))
   `(font-lock-comment-face ((,class (:foreground ,yb-light-gray :slant italic))))
   `(font-lock-comment-delimiter-face ((,class (:foreground ,yb-gray :slant italic))))
   `(font-lock-constant-face ((,class (:foreground ,yb-orange))))
   `(font-lock-doc-face ((,class (:foreground ,yb-light-yellow))))
   `(font-lock-function-name-face ((,class (:foreground ,yb-bright-yellow :weight bold))))
   `(font-lock-keyword-face ((,class (:foreground ,yb-gold :weight bold))))
   `(font-lock-string-face ((,class (:foreground ,yb-cyan))))
   `(font-lock-type-face ((,class (:foreground ,yb-amber))))
   `(font-lock-variable-name-face ((,class (:foreground ,yb-yellow))))
   `(font-lock-warning-face ((,class (:foreground ,yb-red :weight bold))))
   `(font-lock-preprocessor-face ((,class (:foreground ,yb-magenta))))
   
   ;; Mode line
   `(mode-line ((,class (:foreground ,yb-yellow :background ,yb-dark-blue-bg :box (:line-width -1 :style released-button)))))
   `(mode-line-inactive ((,class (:foreground ,yb-gray :background ,yb-blue-bg :box (:line-width -1 :style released-button)))))
   `(mode-line-buffer-id ((,class (:foreground ,yb-bright-yellow :weight bold))))
   
   ;; Search
   `(isearch ((,class (:foreground ,yb-blue-bg :background ,yb-bright-yellow))))
   `(isearch-fail ((,class (:foreground ,yb-white :background ,yb-red))))
   `(lazy-highlight ((,class (:foreground ,yb-blue-bg :background ,yb-gold))))
   
   ;; Line highlighting
   `(hl-line ((,class (:background ,yb-dark-blue-bg))))
   `(linum ((,class (:foreground ,yb-gray :background ,yb-dark-blue-bg))))
   
   ;; Org mode
   `(org-level-1 ((,class (:foreground ,yb-bright-yellow :weight bold :height 1.1))))
   `(org-level-2 ((,class (:foreground ,yb-gold :weight bold))))
   `(org-level-3 ((,class (:foreground ,yb-amber :weight bold))))
   `(org-level-4 ((,class (:foreground ,yb-orange))))
   `(org-level-5 ((,class (:foreground ,yb-cyan))))
   `(org-level-6 ((,class (:foreground ,yb-magenta))))
   `(org-level-7 ((,class (:foreground ,yb-green))))
   `(org-level-8 ((,class (:foreground ,yb-light-yellow))))
   `(org-todo ((,class (:foreground ,yb-red :weight bold))))
   `(org-done ((,class (:foreground ,yb-green :weight bold))))
   `(org-headline-done ((,class (:foreground ,yb-gray))))
   `(org-link ((,class (:foreground ,yb-cyan :underline t))))
   `(org-date ((,class (:foreground ,yb-magenta :underline t))))
   `(org-code ((,class (:foreground ,yb-gold :background ,yb-dark-blue-bg))))
   `(org-block ((,class (:foreground ,yb-yellow :background ,yb-dark-blue-bg))))
   `(org-block-begin-line ((,class (:foreground ,yb-gray :slant italic))))
   `(org-block-end-line ((,class (:foreground ,yb-gray :slant italic))))
   
   ;; Markdown mode
   `(markdown-header-face-1 ((,class (:foreground ,yb-bright-yellow :weight bold :height 1.1))))
   `(markdown-header-face-2 ((,class (:foreground ,yb-gold :weight bold))))
   `(markdown-header-face-3 ((,class (:foreground ,yb-amber :weight bold))))
   `(markdown-header-face-4 ((,class (:foreground ,yb-orange))))
   `(markdown-inline-code-face ((,class (:foreground ,yb-gold :background ,yb-dark-blue-bg))))
   `(markdown-code-face ((,class (:foreground ,yb-yellow :background ,yb-dark-blue-bg))))
   
   ;; Dired
   `(dired-directory ((,class (:foreground ,yb-bright-yellow :weight bold))))
   `(dired-flagged ((,class (:foreground ,yb-red))))
   `(dired-header ((,class (:foreground ,yb-gold :background ,yb-dark-blue-bg :weight bold))))
   `(dired-marked ((,class (:foreground ,yb-orange :weight bold))))
   
   ;; Eshell
   `(eshell-prompt ((,class (:foreground ,yb-gold :weight bold))))
   `(eshell-ls-directory ((,class (:foreground ,yb-bright-yellow :weight bold))))
   `(eshell-ls-executable ((,class (:foreground ,yb-green :weight bold))))
   `(eshell-ls-symlink ((,class (:foreground ,yb-cyan))))
   
   ;; Shell
   `(shell-prompt-face ((,class (:foreground ,yb-gold :weight bold))))
   
   ;; Term
   `(term-color-black ((,class (:foreground ,yb-dark-gray :background ,yb-dark-gray))))
   `(term-color-red ((,class (:foreground ,yb-red :background ,yb-red))))
   `(term-color-green ((,class (:foreground ,yb-green :background ,yb-green))))
   `(term-color-yellow ((,class (:foreground ,yb-yellow :background ,yb-yellow))))
   `(term-color-blue ((,class (:foreground ,yb-very-light-blue :background ,yb-very-light-blue))))
   `(term-color-magenta ((,class (:foreground ,yb-magenta :background ,yb-magenta))))
   `(term-color-cyan ((,class (:foreground ,yb-cyan :background ,yb-cyan))))
   `(term-color-white ((,class (:foreground ,yb-white :background ,yb-white))))
   
   ;; Magit
   `(magit-section-highlight ((,class (:background ,yb-dark-blue-bg))))
   `(magit-diff-file-heading ((,class (:weight bold))))
   `(magit-diff-file-heading-highlight ((,class (:background ,yb-dark-blue-bg :weight bold))))
   `(magit-diff-added ((,class (:foreground ,yb-green :background ,yb-dark-blue-bg))))
   `(magit-diff-added-highlight ((,class (:foreground ,yb-green :background ,yb-lighter-blue-bg))))
   `(magit-diff-removed ((,class (:foreground ,yb-red :background ,yb-dark-blue-bg))))
   `(magit-diff-removed-highlight ((,class (:foreground ,yb-red :background ,yb-lighter-blue-bg))))
   
   ;; Rainbow delimiters
   `(rainbow-delimiters-depth-1-face ((,class (:foreground ,yb-bright-yellow))))
   `(rainbow-delimiters-depth-2-face ((,class (:foreground ,yb-gold))))
   `(rainbow-delimiters-depth-3-face ((,class (:foreground ,yb-amber))))
   `(rainbow-delimiters-depth-4-face ((,class (:foreground ,yb-orange))))
   `(rainbow-delimiters-depth-5-face ((,class (:foreground ,yb-cyan))))
   `(rainbow-delimiters-depth-6-face ((,class (:foreground ,yb-magenta))))
   `(rainbow-delimiters-depth-7-face ((,class (:foreground ,yb-green))))
   `(rainbow-delimiters-depth-8-face ((,class (:foreground ,yb-light-yellow))))
   `(rainbow-delimiters-depth-9-face ((,class (:foreground ,yb-light-gray))))
   
   ;; Flycheck
   `(flycheck-error ((,class (:underline (:style wave :color ,yb-red)))))
   `(flycheck-warning ((,class (:underline (:style wave :color ,yb-orange)))))
   `(flycheck-info ((,class (:underline (:style wave :color ,yb-cyan)))))
   
   ;; Company
   `(company-tooltip ((,class (:foreground ,yb-yellow :background ,yb-dark-blue-bg))))
   `(company-tooltip-annotation ((,class (:foreground ,yb-amber))))
   `(company-tooltip-selection ((,class (:foreground ,yb-bright-yellow :background ,yb-very-light-blue))))
   `(company-tooltip-common ((,class (:foreground ,yb-gold))))
   `(company-scrollbar-bg ((,class (:background ,yb-dark-blue-bg))))
   `(company-scrollbar-fg ((,class (:background ,yb-gray))))
   
   ;; Web mode
   `(web-mode-html-tag-face ((,class (:foreground ,yb-gold))))
   `(web-mode-html-attr-name-face ((,class (:foreground ,yb-amber))))
   `(web-mode-html-attr-value-face ((,class (:foreground ,yb-cyan))))
   `(web-mode-css-selector-face ((,class (:foreground ,yb-gold))))
   `(web-mode-css-property-name-face ((,class (:foreground ,yb-amber))))
   `(web-mode-css-string-face ((,class (:foreground ,yb-cyan))))
   
   ;; JS2 mode
   `(js2-function-param ((,class (:foreground ,yb-amber))))
   `(js2-external-variable ((,class (:foreground ,yb-orange))))
   `(js2-jsdoc-tag ((,class (:foreground ,yb-gray))))
   `(js2-jsdoc-type ((,class (:foreground ,yb-amber))))
   `(js2-jsdoc-value ((,class (:foreground ,yb-cyan))))
   
   ;; TypeScript mode
   `(typescript-jsdoc-tag ((,class (:foreground ,yb-gray))))
   `(typescript-jsdoc-type ((,class (:foreground ,yb-amber))))
   `(typescript-jsdoc-value ((,class (:foreground ,yb-cyan))))
   
   ;; CSS mode
   `(css-selector ((,class (:foreground ,yb-gold))))
   `(css-property ((,class (:foreground ,yb-amber))))
   
   ;; C/C++ mode
   `(c-annotation-face ((,class (:foreground ,yb-magenta))))
   
   ;; Python mode
   `(py-builtins-face ((,class (:foreground ,yb-gold))))
   
   ;; Rust mode
   `(rust-builtin-formatting-macro ((,class (:foreground ,yb-magenta))))
   
   ;; Go mode
   `(go-builtin ((,class (:foreground ,yb-gold))))
   
   ;; Java mode
   `(java-doc-face ((,class (:foreground ,yb-light-yellow :slant italic))))
   
   ;; Lisp mode
   `(lisp-font-lock-keywords ((,class (:foreground ,yb-gold))))
   `(lisp-font-lock-declaration-keywords ((,class (:foreground ,yb-gold :weight bold))))
   
   ;; SML mode
   `(sml-modeline-end-face ((,class (:foreground ,yb-yellow :background ,yb-dark-blue-bg))))
   
   ;; Haskell mode
   `(haskell-operator-face ((,class (:foreground ,yb-gold))))
   
   ;; XML mode
   `(nxml-element-local-name ((,class (:foreground ,yb-gold))))
   `(nxml-attribute-local-name ((,class (:foreground ,yb-amber))))
   `(nxml-tag-delimiter ((,class (:foreground ,yb-gray))))
   
   ;; Show paren
   `(show-paren-match ((,class (:background ,yb-very-light-blue :weight bold))))
   `(show-paren-mismatch ((,class (:background ,yb-red :weight bold))))
   
   ;; Helm
   `(helm-selection ((,class (:background ,yb-lighter-blue-bg))))
   `(helm-match ((,class (:foreground ,yb-bright-yellow :weight bold))))
   `(helm-source-header ((,class (:foreground ,yb-blue-bg :background ,yb-gold :weight bold :height 1.1))))
   
   ;; Ivy
   `(ivy-current-match ((,class (:foreground ,yb-bright-yellow :background ,yb-lighter-blue-bg :weight bold))))
   `(ivy-minibuffer-match-face-1 ((,class (:foreground ,yb-bright-yellow))))
   `(ivy-minibuffer-match-face-2 ((,class (:foreground ,yb-gold :weight bold))))
   `(ivy-minibuffer-match-face-3 ((,class (:foreground ,yb-amber :weight bold))))
   `(ivy-minibuffer-match-face-4 ((,class (:foreground ,yb-orange :weight bold))))
   
   ;; Diff & Ediff
   `(diff-added ((,class (:foreground ,yb-green))))
   `(diff-removed ((,class (:foreground ,yb-red))))
   `(diff-changed ((,class (:foreground ,yb-amber))))
   `(diff-file-header ((,class (:foreground ,yb-gold :weight bold))))
   `(diff-header ((,class (:foreground ,yb-gold :background ,yb-dark-blue-bg))))
   
   ;; Whitespace mode
   `(whitespace-space ((,class (:foreground ,yb-dark-gray))))
   `(whitespace-tab ((,class (:foreground ,yb-dark-gray))))
   `(whitespace-newline ((,class (:foreground ,yb-dark-gray))))
   
   ;; ERC
   `(erc-nick-default-face ((,class (:foreground ,yb-gold :weight bold))))
   `(erc-prompt-face ((,class (:foreground ,yb-bright-yellow :background ,yb-dark-blue-bg :weight bold))))
   `(erc-notice-face ((,class (:foreground ,yb-gray))))
   `(erc-timestamp-face ((,class (:foreground ,yb-cyan))))
   
   ;; Info
   `(info-title-1 ((,class (:foreground ,yb-bright-yellow :weight bold :height 1.2))))
   `(info-title-2 ((,class (:foreground ,yb-gold :weight bold :height 1.1))))
   `(info-title-3 ((,class (:foreground ,yb-amber :weight bold))))
   `(info-title-4 ((,class (:foreground ,yb-orange))))
   
   ;; Message
   `(message-header-name ((,class (:foreground ,yb-gray))))
   `(message-header-subject ((,class (:foreground ,yb-bright-yellow :weight bold))))
   `(message-header-to ((,class (:foreground ,yb-gold))))
   `(message-header-other ((,class (:foreground ,yb-amber))))
   `(message-cited-text ((,class (:foreground ,yb-light-gray :slant italic))))
   
   ;; Compilation
   `(compilation-info ((,class (:foreground ,yb-green))))
   `(compilation-warning ((,class (:foreground ,yb-orange))))
   `(compilation-error ((,class (:foreground ,yb-red))))
   
   ;; Tabs
   `(tab-bar ((,class (:foreground ,yb-yellow :background ,yb-dark-blue-bg))))
   `(tab-bar-tab ((,class (:foreground ,yb-bright-yellow :background ,yb-blue-bg :box (:line-width -1 :style released-button)))))
   `(tab-bar-tab-inactive ((,class (:foreground ,yb-gray :background ,yb-dark-blue-bg :box (:line-width -1 :style released-button)))))
   
   ;; Line numbers
   `(line-number ((,class (:foreground ,yb-gray :background ,yb-dark-blue-bg))))
   `(line-number-current-line ((,class (:foreground ,yb-bright-yellow :background ,yb-dark-blue-bg :weight bold))))
   
   ;; LSP
   `(lsp-face-highlight-textual ((,class (:background ,yb-lighter-blue-bg))))
   `(lsp-face-highlight-read ((,class (:background ,yb-lighter-blue-bg))))
   `(lsp-face-highlight-write ((,class (:background ,yb-lighter-blue-bg))))
   ))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'yellow-blue)
;;; yellow-blue-theme.el ends here
