;;; masquerade-mode.el --- Minor mode to add templating capabilities to any mode
;;--------------------------------------------------------------------
;;
;; Copyright (C) 2013, Diego Sevilla <dsevilla@ditec.um.es>
;;
;; This file is NOT part of Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA
;;
;; To use, save masquerade-mode.el to a directory in your load-path.
;;
;; (require 'masquerade-mode)
;; (add-hook 'c++-mode-hook 'turn-on-masquerade-mode)
;; (add-hook 'emacs-lisp-mode-hook 'turn-on-masquerade-mode)
;;
;; or
;;
;; M-x masquerade-mode
;;

(defcustom masq-foreground-color "Blue"
  "Font foreground colour"
  :group 'masquerade-mode)

(defcustom masq-background-color  "Yellow"
  "Font background color"
  :group 'masquerade-mode)

(make-variable-buffer-local
 (defcustom masq-macro-start "«"
   "Marker for the beginning of a sexp that will be a macro"
   :group 'masquerade-mode))

(make-variable-buffer-local
 (defcustom masq-macro-end "»"
   "Marker for the end of a sexp that will be a macro"
   :group 'masquerade-mode))

(defcustom font-lock-masq-face 'font-lock-masq-face
  "variable storing the face for masquerade mode"
  :group 'masquerade-mode)

;; (make-face 'font-lock-masq-face)
;; (modify-face 'font-lock-masq-face masq-foreground-color
;;              masq-background-color nil t nil t nil nil)

(defun masq-expand-buffer ()
  (interactive)
  (let ((expand-buffer (get-buffer-create (concat "*expand* " (buffer-name)))))
    (copy-to-buffer expand-buffer (point-min) (point-max))
    (with-current-buffer expand-buffer
      (goto-char (point-min))
      (while (re-search-forward masq-macro-start nil t)
        (let* ((subst-start (match-beginning 0))
               ;; Point is already now at the beginning of the sexp.
               ;; read will take care of advancing the point to the
               ;; beginning of the masq-macro-end
               (lisp-obj (read (current-buffer)))
               (eval-string-result
                (with-output-to-string (princ (eval lisp-obj)))))
          (re-search-forward masq-macro-end nil t)
          (delete-region subst-start (point))
          (insert eval-string-result))))))


;;;###autoload
(define-minor-mode masquerade-mode "Minor mode to add templating capabilities to any mode"
  :lighter " Masq" :group 'masquerade-mode
  ;; Will expand macros and fontify buffer here
  )

(defun turn-on-masquerade-mode ()
  "turn masquerade-mode on"
  (interactive)
  (masquerade-mode 1))

(provide 'masquerade-mode)
