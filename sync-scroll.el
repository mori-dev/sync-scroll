;;; sync-scroll.el --- Scroll Up and Scroll Down 2 window.

;; Copyright (C) 2011-2012 mori_dev

;; Author: mori_dev <mori.dev.asdf@gmail.com>
;; Keywords: scroll, utility
;; Prefix: sync-scroll-

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

;;; Setting Sample

;; (require 'sync-scroll)
;; (global-set-key (kbd "C-6") 'sync-scroll-quit)
;; (defalias 'q 'sync-scroll-quit)

(eval-when-compile (require 'cl))

(defvar sync-scroll-window-configuration nil)
(defvar sync-scroll-mode-buffers nil)

(defvar sync-scroll-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<down>") 'sync-scroll-one-line-up)
    (define-key map (kbd "<up>") 'sync-scroll-one-line-down)
    map))

(define-minor-mode sync-scroll-mode
  "Sync Scroll mode"
  :lighter " SS"
  :global nil
  :init-value nil
  :group 'sync-scroll
  :keymap sync-scroll-mode-map
  ())

(defun sync-scroll-mode-on ()
  (interactive)
  (sync-scroll-mode 1))

(defun sync-scroll-mode-off ()
  (interactive)
  (sync-scroll-mode -1))

(defun sync-scroll-quit ()
  (interactive)
  (sync-scroll-mode -1)
  (dolist (buffer sync-scroll-mode-buffers)
    (progn
      (with-current-buffer buffer
        (sync-scroll-mode-off))
      (setq sync-scroll-mode-buffers (delete buffer sync-scroll-mode-buffers))))
  (sync-scroll-recover-window-configuration))

(defun sync-scroll-save-window-configuration ()
  (interactive)
  (setq sync-scroll-window-configuration (current-window-configuration)))

(defun sync-scroll-recover-window-configuration ()
  (interactive)
  (when sync-scroll-window-configuration
    (set-window-configuration sync-scroll-window-configuration)
    (setq sync-scroll-window-configuration nil)))

(defun sync-scroll-select-buffer (buffer-a buffer-b)
  (interactive
   (list (read-buffer "Buffer A to Sync Scroll: ")
         (read-buffer "Buffer B to Sync Scroll: ")))
   (sync-scroll (buffer-a buffer-b)))

(defun sync-scroll (buffer-a buffer-b)
  (add-to-list 'sync-scroll-mode-buffers buffer-a)
  (add-to-list 'sync-scroll-mode-buffers buffer-b)

  (sync-scroll-save-window-configuration)
  (delete-other-windows)
  (split-window-horizontally)
  (save-selected-window
    (let ((wl (get-buffer-window-list)))
      (select-window (first wl))
      (display-buffer buffer-a)
      (with-current-buffer buffer-a
        (sync-scroll-mode-on))
      (select-window (second wl))
      (display-buffer buffer-b)
      (with-current-buffer buffer-b
        (sync-scroll-mode-on)))))

(defun sync-scroll-one-line-up ()
  (interactive)
  (scroll-up 1)
  (scroll-other-window 1))

(defun sync-scroll-one-line-down ()
  (interactive)
  (scroll-down 1)
  (scroll-other-window-down 1))

(provide 'sync-scroll)