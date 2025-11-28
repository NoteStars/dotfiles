
;; Tell Emacs to intrpret "Alt" to "Meta"
;; This covers both left-Alt and right-Alt (AltGr). If you only want the left side, you'll need a tiny extra step.
;;(setq x-alt-keysum 'meta)  ; Alt -> Meta

;; Keep the Super/Windows key from stealing Meta.
;; If you ever use the Super Key for other shutcuts, make sure Emacs doesn't treat it as Meta.
;;(setq x-super-keysym nil)  ; Super -> Nothing 

;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;

;;(Install org-present if needed
(unless (package-installed-p 'org-present)
  (package-install 'org-present))

(unless (package-installed-p 'org-bullets-mode)
  (package-install 'org-bullets-mode))

(use-package! org-bullets
    :hook (org-mode . org-bullets-mode)
    :config
)

(load! "elcord.el")
(elcord-mode)

(defun elcord--disable-elcord-if-no-frames (f)
  (declare (ignore f))
  (when (let ((frames (delete f (visible-frame-list))))
          (or (null frames)
              (and (null (cdr frames))
                   (eq (car frames) terminal-frame))))
    (elcord-mode -1)
    (add-hook 'after-make-frame-functions 'elcord--enable-on-frame-created)))

(defun elcord--enable-on-frame-created (f)
  (declare (ignore f))
  (elcord-mode +1))

(defun elcord--cleanup-on-exit ()
  "Ensure Discord RPC is properly closed when Emacs exits."
  (when elcord-mode
    ;; Cancel the timer if it exists
    (when (boundp 'elcord--update-timer)
      (when elcord--update-timer
        (cancel-timer elcord--update-timer)
        (setq elcord--update-timer nil)))
    ;; Try to clear presence without waiting for response
    (condition-case nil
        (elcord--send-presence "")
      (error nil))))

(defun my/elcord-mode-hook ()
  (if elcord-mode
      (progn
        (add-hook 'delete-frame-functions 'elcord--disable-elcord-if-no-frames)
        (add-hook 'kill-emacs-hook 'elcord--cleanup-on-exit))
    (remove-hook 'delete-frame-functions 'elcord--disable-elcord-if-no-frames)
    (remove-hook 'kill-emacs-hook 'elcord--cleanup-on-exit)))

(add-hook 'elcord-mode-hook 'my/elcord-mode-hook)

(use-package! org-present
  :after org
  :config
  ;; Optional: customize org-present behavior
  (add-hook 'org-present-mode-hook
            (lambda ()
              (org-present-big)
              (org-display-inline-images)
              (org-present-hide-cursor)
              (org-present-read-only)))

  (add-hook 'org-present-mode-quit-hook
            (lambda ()
              (org-present-small)
              (org-remove-inline-images)
              (org-present-show-cursor)
              (org-present-read-write))))
