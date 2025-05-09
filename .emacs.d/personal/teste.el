(defun testibus--preview (action cand)
  (pcase action
    ('preview
     (with-current-buffer-window " *testibus*" 'action nil
       (erase-buffer)
       (insert (format "input: %s\n" cand))))))

(consult--read
 (consult--dynamic-collection
  (lambda (input callback)
    (dotimes (i 3)
      (sleep-for 0.1) ;; Simulate work
      (funcall callback (mapcar (lambda (s) (format "%s%s" s i))
                                (split-string input nil t))))))
 :prompt "run testibus: "
 :state #'testibus--preview)

(defvar dart-errors--cache nil "Cache of dart analysis errors.")

(defun dart-errors--analyze ()
  "Run dart analyze and parse the results."
  (let ((error-file (expand-file-name ".dart_errors" (project-root (project-current)))))
    ;; Run dart analyze and save output to .dart_errors
    (call-process "dart" nil `(:file ,error-file) nil "analyze" "--format=machine")
    ;; Read and parse the error file
    (setq dart-errors--cache
          (when (file-exists-p error-file)
            (with-temp-buffer
              (insert-file-contents error-file)
              (let ((errors nil))
                (goto-char (point-min))
                (while (not (eobp))
                  (let ((line (buffer-substring-no-properties 
                               (line-beginning-position) (line-end-position))))
                    (when (string-match "^\\(ERROR\\|COMPILE_TIME_ERROR\\|WARNING\\)" line)
                      (push line errors)))
                  (forward-line 1))
                (nreverse errors)))))))

(defun dart-errors--preview (action cand)
  "Preview function for dart errors.
ACTION is one of 'setup, 'preview, 'exit, or 'return.
CAND is the current candidate being previewed."
  (pcase action
    ('setup
     (unless dart-errors--cache
       ;; Run the analyzer when setting up
       (dart-errors--analyze)))

    ('preview
     (with-current-buffer-window " *dart-errors*" 'action nil
       (erase-buffer)
       (if cand
           (let* ((parts (split-string cand "|"))
                  (parts-length (length parts)))
             ;; Only process if we have enough parts
             (if (>= parts-length 8)
                 (let ((file-path (nth 3 parts))
                       (line-num (string-to-number (nth 4 parts)))
                       (col-start (string-to-number (nth 5 parts))))
                   ;; Insert file content if available
                   (if (and file-path (file-exists-p file-path))
                       (progn
                         (insert-file-contents file-path)
                         ;; Highlight the error line
                         (goto-char (point-min))
                         (forward-line (1- line-num))
                         (let ((line-start (line-beginning-position))
                               (line-end (line-end-position)))
                           ;; Create overlay to highlight the line
                           (let ((ov (make-overlay line-start line-end)))
                             (overlay-put ov 'face '(:background "#ffe0e0"))
                             ;; Add a marker at the column position
                             (when (> col-start 0)
                               (goto-char (+ line-start (1- col-start)))
                               (overlay-put (make-overlay (point) (1+ (point)))
                                           'face '(:background "red" :foreground "white")))))))
                   )
               ;; Not enough parts, just show the raw candidate
               (insert (format "Invalid format: %s" cand))))
         (insert "No selection"))))
    ))

(defun dart-errors--state ()
  "Grep state function."
  (let ((open (consult--temporary-files))
        )
    (lambda (action cand)
      (unless cand
        (funcall open))
      )))

(defun dart-errors-jump ()
  "Jump to Dart errors using consult."
  (interactive)

  (consult--read
   (consult--dynamic-collection
    (lambda (input)
      (if (string-empty-p input)
          dart-errors--cache
        (let ((results nil))
          (dolist (item dart-errors--cache)
            (when (string-match-p (regexp-quote input) item)
              (push item results)))
          (nreverse results)))))
   :prompt "Dart error: "
   :require-match t
   :state (dart-errors--state) ))
