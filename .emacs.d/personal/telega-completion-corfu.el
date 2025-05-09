;;; telega-completion-corfu.el --- Corfu-based username completion for telega -*- lexical-binding: t -*-

;; Author: Your Name
;; Keywords: convenience
;; Package-Requires: ((emacs "27.1") (telega "0.7.0") (corfu "0.25"))

;;; Commentary:
;; This package provides Corfu-based username completion for telega.

;;; Code:

(require 'telega)

(defun my/telega-grab-username-at-point ()
  "Grab string starting with `@' at point."
  (let ((pos (point))
        (line-start (line-beginning-position)))
    ;; Search backward for the @ character
    (save-excursion
      (when (search-backward "@" line-start t)
        (let ((start (point))
              (end pos))
          (when (<= start (1- end)) ; Make sure we have at least one character
            (let ((text (buffer-substring-no-properties start end)))
              (cons start end))))))))

(defun my/telega-username-completions (prefix)
  "Generate username completions for the given PREFIX."
  (when (string-prefix-p "@" prefix)
    (let* ((prefix-without-@ (substring prefix 1))
           (members
            (progn
              (telega--searchChatMembers
                  telega-chatbuf--chat prefix-without-@
                  (if (string-prefix-p "@" prefix-without-@) ; For "@@" admin filter
                      '(:@type "chatMembersFilterAdministrators")
                    (list :@type "chatMembersFilterMention"
                          :message_thread_id (telega-chatbuf--message-thread-id)))))))
      ;; Format members as completion candidates
      (let ((candidates
             (mapcar (lambda (member)
                       (let ((candidate (propertize
                                         (or (telega-msg-sender-username member 'with-@)
                                             (telega-msg-sender-title member))
                                         'telega-member member)))
                         candidate))
                     ;; Filter out deleted and blocked users
                     (cl-remove-if (telega-match-gen-predicate 'sender
                                     '(or is-blocked (user is-deleted)))
                                   members))))
        candidates))))

(defun my/telega-username-completion-at-point ()
  "Completion at point function for Telegram usernames."
  (when (eq major-mode 'telega-chat-mode)
    (let ((bounds (my/telega-grab-username-at-point)))
      (when bounds
        (list (car bounds) ; start
              (cdr bounds) ; end
              (completion-table-dynamic
               #'my/telega-username-completions)
              :exclusive 'no
              :annotation-function
              (lambda (candidate)
                (when-let ((member (get-text-property 0 'telega-member candidate)))
                  (concat "  "
                          (telega-ins--as-string
                           (telega-ins--msg-sender member
                             :with-avatar-p telega-company-username-show-avatars)))))
              :exit-function
              (lambda (candidate _status)
                (when-let ((member (get-text-property 0 'telega-member candidate)))
                  ;; Insert a space after completion
                  (insert " "))))))))

(defun my/telega-complete-username-with-minibuffer ()
  "Complete username using minibuffer-based completion.
Uses telega's insertion approach similar to company backend."
  (interactive)
  (let ((bounds (my/telega-grab-username-at-point)))
    (when bounds
      (let* ((start (car bounds))
             (end (cdr bounds))
             (prefix (buffer-substring-no-properties start end))
             (completions (my/telega-username-completions prefix))
             (selected (completing-read "Username: " completions nil t prefix)))

        ;; Handle the insertion similar to telega-company-username post-completion
        (when (string-prefix-p "@" selected)
          ;; Delete the original text first
          (delete-region (- (point) (length prefix)) (point))

          ;; For users, handle special formatting
          (telega-ins selected)
          
          ;; Always add a space after completion like in company version
q          (insert " ")
          
          ;; Check for inline bot handling (similar to company version)
          (let ((chatbuf-input (telega-chatbuf-input-string)))
            (when (or (member chatbuf-input telega-known-inline-bots)
                      (member chatbuf-input telega--recent-inline-bots))
              (telega-chatbuf-attach-inline-bot-query 'no-search))))))))

;; Define your custom emoji list
(defvar my/custom-emoji-alist
  '((":smile:" . "😊")
    (":laught:" . "😂")
    (":heart:" . "❤️")
    (":ops:" . "😅")
    (":hm:" . "🤔")
    (":grin:" . "😁")
    (":vomit:" . "🤮")
    (":heh:" . "😈")
    (":callme:" . "🤙")
    (":th:" . "💦")
    )
  "Custom list of emoji names and their corresponding emoji characters.")

;; Derived variable to store just the emoji names for quicker matching
(defvar my/custom-emoji-candidates
  (mapcar #'car my/custom-emoji-alist)
  "List of emoji names for completion candidates.")

(defun my/telega-grab-emoji-at-point ()
  "Grab string starting with `:' at point."
  (let ((pos (point))
        (line-start (line-beginning-position)))
    ;; Search backward for the : character
    (save-excursion
      (when (search-backward ":" line-start t)
        (let ((start (point))
              (end pos))
          (when (<= start (1- end)) ; Make sure we have at least one character
            (cons start end)))))))

(defun my/telega-emoji-completions (prefix)
  "Generate emoji completions for the given PREFIX."
  (when (string-prefix-p ":" prefix)
    (let* ((prefix-without-colon (substring prefix 1))
           (candidates
            (cl-remove-if-not
             (lambda (emoji-name)
               (string-match-p (regexp-quote prefix-without-colon) emoji-name))
             my/custom-emoji-candidates)))
      candidates)))

(defun my/emoji-annotation (candidate)
  "Show emoji annotation for CANDIDATE."
  (concat " " (cdr (assoc candidate my/custom-emoji-alist))))

(defun my/telega-emoji-completion-at-point ()
  "Completion at point function for custom emojis."
  (let ((bounds (my/telega-grab-emoji-at-point)))
    (when bounds
      (list (car bounds)
            (cdr bounds)
            (completion-table-dynamic
             #'my/telega-emoji-completions)
            :exclusive 'no
            :annotation-function
            #'my/emoji-annotation
            :exit-function
            (lambda (candidate _status)
              (let ((emoji (cdr (assoc candidate my/custom-emoji-alist))))
                ;; Delete the completed text (e.g. ":smi")
                (delete-region (car bounds) (point))
                ;; Insert the actual emoji
                (insert emoji)))))))

(defun my/telega-setup-emoji-completion ()
  "Setup emoji completion for telega chat buffer."
  (add-hook 'completion-at-point-functions
            #'my/telega-emoji-completion-at-point nil t)
  t) ; Return t to confirm successful setup

(defun my/telega-setup-username-completion ()
  "Setup username completion for telega chat buffer."
  (add-hook 'completion-at-point-functions
            #'my/telega-username-completion-at-point nil t)
  t) ; Return t to confirm successful setup

;; Combined setup function
(defun my/telega-setup-completion ()
  "Setup both username and emoji completion for telega chat buffer."
  (my/telega-setup-username-completion)
  (my/telega-setup-emoji-completion))

(provide 'telega-completion-corfu)
;;; telega-completion-corfu.el ends here
