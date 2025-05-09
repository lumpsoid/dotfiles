;;; lump-md.el --- Refactor markdown notes with YAML frontmatter -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Your Name

;; Author: Your Name <your.email@example.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (markdown-mode "2.3"))
;; Keywords: files, markdown, notes
;; URL: https://github.com/yourusername/lump-md

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides functionality to refactor markdown notes by adding
;; YAML frontmatter and renaming files according to a consistent pattern.
;; 
;; The main functions are:
;; - `lump-md-note': Refactor a single markdown note interactively
;; - `lump-md-all-notes': Refactor all markdown notes in a directory
;; - `lump-md-rename-files': Rename markdown files in a directory

;;; Code:

(require 'markdown-mode nil t)

;;;; Internal Functions

(defun lump-md--extract-date-from-filename (filename)
  "Extract date from filename with format YYYYMMDDHHmmss."
  (when (string-match "\\([0-9]\\{14\\}\\)" filename)
    (match-string 1 filename)))

(defun lump-md--format-date-for-frontmatter (date-string)
  "Format YYYYMMDDHHmmss date as YYYY-MM-DDTHHmmss."
  (when date-string
    (concat
     (substring date-string 0 4) "-"
     (substring date-string 4 6) "-"
     (substring date-string 6 8) "T"
     (substring date-string 8 10) ":"
     (substring date-string 10 12) ":"
     (substring date-string 12 14))))

(defun lump-md--update-file-timestamp (file date-string)
  "Update the file's creation and modification dates based on the timestamp."
  (when date-string
    ;; Format date for touch command: YYYYMMDDHHmm.ss
    (let ((formatted-date 
           (concat
            (substring date-string 0 12) "." 
            (substring date-string 12 14))))
      (call-process "touch" nil nil nil "-t" formatted-date file))))

(defun lump-md--extract-title-and-tags (file)
  "Extract title from first line and tags from second line of file.
   Title is trimmed and # symbols are removed from the left side.
   Tags are split by whitespace and # symbols are removed from each."
  (with-temp-buffer
    (insert-file-contents file)
    (let ((raw-title (progn (goto-char (point-min))
                     (buffer-substring-no-properties
                      (line-beginning-position)
                      (line-end-position))))
        (raw-tags (progn (forward-line 1)
                     (buffer-substring-no-properties
                      (line-beginning-position)
                      (line-end-position)))))
    ;; Process title: trim and remove # symbols
    (let ((title (string-trim raw-title))
          (tags-list '()))
      ;; Remove leading # symbols from title
      (when (string-match "^\\(#+\\s-*\\)\\(.*\\)" title)
        (setq title (match-string 2 title)))
      (setq title (string-trim title))
      
      ;; Process tags: split by whitespace and remove # from each
      (dolist (tag (split-string raw-tags))
        (when (string-match "^#\\(.*\\)" tag)
          (push (match-string 1 tag) tags-list)))
      
      (list title tags-list)))))

(defun lump-md--create-identifier (date-string)
  "Create identifier in format YYYYMMDDTHHMMSS from date string."
  (when date-string
    (concat
     (substring date-string 0 4)
     (substring date-string 4 6)
     (substring date-string 6 8)
     "T"
     (substring date-string 8 10)
     (substring date-string 10 12)
     (substring date-string 12 14))))

(defun lump-md--generate-frontmatter (title tags-list date &optional identifier)
  "Generate YAML frontmatter with title, tags, date and identifier."
  (let ((id (or identifier (lump-md--create-identifier date))))
    (concat "---\n"
            "title:      \"" title "\"\n"
            "date:       " date "\n"
            "tags:       " (format "[%s]" 
                          (mapconcat (lambda (tag) (concat "\"" tag "\"")) 
                                    tags-list ", ")) "\n"
            "identifier: \"" id "\"\n"
            "---\n\n")))

;; Composable naming functions
(defun lump-md--create-date-prefix (date-string)
  "Create date prefix in format YYYYMMDDTHHMMSS from date string."
  (when date-string
    (lump-md--create-identifier date-string)))

(defun lump-md--create-title-slug (title)
  "Create a slug from title."
  (let ((slug (replace-regexp-in-string "[^a-zA-Z0-9]" "-" (downcase (string-trim title)))))
    ;; Remove consecutive dashes and trailing dashes
    (replace-regexp-in-string "-+" "-" (replace-regexp-in-string "-+$" "" slug))))

(defun lump-md--create-tags-suffix (tags-list)
  "Create a tags suffix from a list of tags."
  (mapconcat 'identity tags-list "_"))

(defun lump-md--build-filename (date-string title tags-list extension)
  "Build a filename in format YYYYMMDDTHHMMSS--title-slug__tags_list.extension."
  (let ((date-prefix (lump-md--create-date-prefix date-string))
        (title-slug (lump-md--create-title-slug title))
        (tags-suffix (lump-md--create-tags-suffix tags-list)))
    (concat date-prefix
            "--" title-slug
            (if (and tags-list (> (length tags-list) 0))
                (concat "__" tags-suffix)
              "")
            "." extension)))

(defun lump-md--update-references-using-system (old-pattern new-pattern &optional directory)
  "Update all references from OLD-PATTERN to NEW-PATTERN in files under DIRECTORY.
If DIRECTORY is nil, use the current directory."
  ;; Set default directory if not provided
  (unless directory
    (setq directory default-directory))
  
  ;; Check for required tools
  (unless (and (executable-find "rg") (executable-find "sd"))
    (user-error "This function requires both 'rg' and 'sd' to be installed and in your PATH"))
  
  (let ((output-buffer-name "*lump-references-output*"))
    ;; if previous one was not cleared after use
    (when (get-buffer output-buffer-name)
      (kill-buffer output-buffer-name))
  
    (let ((output-buffer (get-buffer-create output-buffer-name)))
      (with-current-buffer output-buffer
        (erase-buffer)
        (insert (format "Updating references from '%s' to '%s' in %s\n\n" 
                        old-pattern new-pattern directory)
                "Process started. Please wait...\n\n")
        
        ;; Run the command using the correct syntax with command substitution and redirection
        (let* ((default-directory (or directory default-directory))
               ;; Use the command substitution approach you demonstrated
               (cmd (format "sd -F %s %s $(rg --files-with-matches -F --glob '*.{md,org,txt}' %s)"
                            (shell-quote-argument old-pattern)
                            (shell-quote-argument new-pattern)
                            (shell-quote-argument old-pattern)))
               (proc (start-process-shell-command 
                      "lump-references-process" 
                      output-buffer 
                      cmd)))

          ;; Setup process sentinel to handle completion
          (set-process-sentinel 
           proc
           (lambda (process event)
             (with-current-buffer output-buffer
               (goto-char (point-max))
               (let ((status (process-exit-status process)))
                 (insert (format "\n\nCommand completed with status: %d" status))
                 (if (= status 0)
                     ;;(insert "\nReferences updated successfully.")
                     (kill-buffer output-buffer)
                   (insert "\nThere was an error updating references.")
                   ;; Make buffer read-only and set up 'q' to close buffer
                   (goto-char (point-min))
                   (local-set-key (kbd "q") (lambda () (interactive) (quit-window t)))
                   (setq-local header-line-format 
                               "Press 'q' to close this buffer")
                   ;; Make buffer visible
                   (setq buffer-read-only t)
                   (select-window (display-buffer output-buffer))))))))   
      
        ;; Return the process object
        t))))

;;;; Public Functions

;;;###autoload
(defun lump-md-note (file)
  "Refactor a markdown note interactively by showing preview and asking for title and tags.
If the current buffer is a markdown file with a matching pattern, its path will be
used as the default completion."
  (interactive
   (let ((default-file (when (and buffer-file-name
                                  (string-match "\\.\\(md\\|org\\)$" buffer-file-name)
                                  (string-match "\\([0-9]\\{14\\}\\)" (file-name-nondirectory buffer-file-name)))
                         buffer-file-name)))
     (list (read-file-name "Select note file: "
                           (when default-file (file-name-directory default-file))
                           default-file
                           t
                           (when default-file (file-name-nondirectory default-file))))))
  (let* ((filename (file-name-nondirectory file))
         (date-string (lump-md--extract-date-from-filename filename))
         (formatted-date (lump-md--format-date-for-frontmatter date-string))
         (identifier (lump-md--create-identifier date-string))
         (title-and-tags (lump-md--extract-title-and-tags file))
         (initial-title (nth 0 title-and-tags))
         (initial-tags-list (nth 1 title-and-tags))
         (preview-buffer (generate-new-buffer "*Note Preview*"))
         (new-title "")
         (new-tags-list '())
         (apply-changes nil)
         (old-link-pattern nil)
         (new-link-pattern nil))

    ;; Show original file content in a preview buffer
    (with-current-buffer preview-buffer
      (insert-file-contents file)
      (when (fboundp 'markdown-mode)
        (markdown-mode)) ; Use markdown-mode for syntax highlighting if available
      (goto-char (point-min))
      (display-buffer preview-buffer))
    
    ;; Ask for new title
    (setq new-title (read-string "Enter new title: " initial-title))
    
    ;; Ask for new tags (comma separated)
    (let ((tags-input (read-string "Enter tags (comma separated): " 
                                   (mapconcat 'identity initial-tags-list ","))))
      (setq new-tags-list 
            (mapcar 'string-trim (split-string tags-input "," t))))
    
    ;; Calculate new filename
    (let* ((extension (file-name-extension file))
           (new-filename (lump-md--build-filename date-string new-title new-tags-list extension))
           (frontmatter (lump-md--generate-frontmatter new-title new-tags-list formatted-date identifier)))

      ;; Create the link patterns for searching
      (setq old-link-pattern (concat "[[" date-string "]]"))
      (setq new-link-pattern (concat "[[" (file-name-sans-extension new-filename) "]]"))
      
      ;; Update preview buffer to show changes
      (with-current-buffer preview-buffer
        (erase-buffer)
        ;; Show proposed changes at the top
        (insert "Current filename: " filename "\n")
        (insert "New filename:     " new-filename "\n\n")
        (insert "Frontmatter to be added:\n")
        (insert frontmatter)
        (insert "\nFile content (with first two lines to be replaced by frontmatter):\n")
        (insert-file-contents file)
        (goto-char (point-min)))
      
      ;; Ask whether to apply changes
      (when (y-or-n-p "Apply these changes? ")
        (setq apply-changes t))
      
      ;; Clean up the preview buffer
      (kill-buffer preview-buffer)
      
      (when apply-changes
        ;; Create backup file (only once)
        (let ((backup-file (concat file "~")))
          (copy-file file backup-file t))
  
        ;; Update the file's timestamp
        (lump-md--update-file-timestamp file date-string)
  
        ;; Create a new buffer with the modified content and new filename
        (let* ((dir (file-name-directory file))
               (new-path (concat dir new-filename))
               (modified-buffer (generate-new-buffer new-filename)))

          ;; Populate the buffer with new content
          (with-current-buffer modified-buffer
            ;; Get the content of the original file
            (insert-file-contents file)
            (goto-char (point-min))

            ;; Remove the original title and tags lines
            (let ((count 0))
              (while (and (< count 2)
                          (not (eobp))
                          (looking-at "^#"))
                (forward-line 1)
                (setq count (1+ count))))
            (delete-region (point-min) (point))
            (goto-char (point-min))

      
            ;; Replace the beginning with frontmatter
            (insert frontmatter)
            (goto-char (point-min))
      
            ;; Enable markdown-mode if available
            (when (fboundp 'markdown-mode)
              (markdown-mode)))
    
          ;; Display the buffer for the user to review and save themselves
          (switch-to-buffer modified-buffer)
    
          ;; Ask if the user wants to update references
          (when (y-or-n-p "Update references to this file in other notes? ")
            ;; Call the function to update references
            (lump-md--update-references-using-system old-link-pattern
                                                     new-link-pattern
                                                     dir))

          ;; clean processed file from emacs and directory
          (delete-file file)
          (when (get-buffer filename)
            (kill-buffer filename))
          
          (message "Note refactored into new buffer. Save it when you're ready.")))
      (unless apply-changes
        (message "Refactoring canceled")))))

;;;###autoload
(defun lump-md-all-notes (directory)
  "Refactor all markdown notes in the specified directory."
  (interactive "DSelect directory: ")
  (let ((files (directory-files directory t "\\.md$\\|\\.org$")))
    (dolist (file files)
      (message "Processing %s" file)
      ;; Non-interactive version for batch processing
      (let* ((filename (file-name-nondirectory file))
             (date-string (lump-md--extract-date-from-filename filename))
             (formatted-date (lump-md--format-date-for-frontmatter date-string))
             (identifier (lump-md--create-identifier date-string))
             (title-and-tags (lump-md--extract-title-and-tags file))
             (title (nth 0 title-and-tags))
             (tags-list (nth 1 title-and-tags))
             (frontmatter (lump-md--generate-frontmatter title tags-list formatted-date identifier))
             (extension (file-name-extension file))
             (new-filename (lump-md--build-filename date-string title tags-list extension))
             (preview-buffer (generate-new-buffer "*Note Preview*")))
        
        ;; Show preview of changes
        (with-current-buffer preview-buffer
          (insert "Current filename: " filename "\n")
          (insert "New filename:     " new-filename "\n\n")
          (insert "Frontmatter to be added:\n")
          (insert frontmatter)
          (insert "\nFile content (with first two lines to be replaced by frontmatter):\n")
          (insert-file-contents file)
          (goto-char (point-min))
          (display-buffer preview-buffer))
        
        ;; Ask whether to apply changes
        (when (y-or-n-p (format "Apply changes to %s? " filename))
          ;; Create backup file
          (let ((backup-file (concat file "~")))
            (copy-file file backup-file t))
          
          ;; Update the file's timestamp
          (lump-md--update-file-timestamp file date-string)
          
          ;; Add frontmatter to the file
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (insert frontmatter)
            ;; Skip the title and tags lines as they're now in frontmatter
            (forward-line 2)
            (let ((new-file (concat file ".new")))
              (write-region (point) (point-max) new-file)
              (rename-file new-file file t))
            (message "Added frontmatter to %s (backup created as %s~)" file file))
          
          ;; Rename file to new format
          (when (y-or-n-p (format "Rename %s to new format? " filename))
            (let* ((dir (file-name-directory file))
                   (new-path (concat dir new-filename)))
              (rename-file file new-path t)
              (message "File renamed to %s (backup created as %s.renamed~)" new-filename file))))
        
        ;; Clean up the preview buffer
        (kill-buffer preview-buffer)))))

;;;###autoload
(defun lump-md-rename-files (directory &optional target-extension)
  "Rename markdown files to YYYYMMDDTHHMMSS--title-slug__tags_list.extension."
  (interactive "DSelect directory: ")
  (let* ((files (directory-files directory t "\\.md$\\|\\.org$"))
         (extension (or target-extension "org")))
    (dolist (file files)
      (let* ((filename (file-name-nondirectory file))
             (date-string (lump-md--extract-date-from-filename filename))
             (title-and-tags (lump-md--extract-title-and-tags file))
             (title (nth 0 title-and-tags))
             (tags-list (nth 1 title-and-tags))
             (new-name (if date-string
                          (lump-md--build-filename date-string title tags-list extension)
                        filename)))
        
        (when (and date-string (not (string= filename new-name)))
          ;; Ask whether to apply changes
          (when (y-or-n-p (format "Rename %s to %s? " filename new-name))
            ;; Create backup file
            (let ((backup-file (concat file "~")))
              (copy-file file backup-file t))
            (rename-file file (concat (file-name-directory file) new-name) t)
            (message "Renamed %s to %s (backup created as %s~)" filename new-name file)))))))

;;;; Provide Features

(provide 'lump-md)
;;; lump-md.el ends here
