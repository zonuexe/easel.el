;;; easel.el --- Interface for easel lean canvas

;; Copyright (C) 2016 USAMI Kenta

;; Author: USAMI Kenta <tadsan@zonu.me>
;; Created: 7 Aug 2016
;; Version: 0.0.1
;; Keywords: markdown leancanvas
;; Package-Requires: ((emacs "24") (prodigy "0.6.0"))

;; This file is NOT part of GNU Emacs.

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

;;; Code:
(require 'prodigy)

(defvar easel-executable-bin nil
  "Path to `easel' exec file.")

(defvar easel-target-file nil)

(defvar easel-server-url "http://localhost:3000/")

(defvar easel-export-target-html-path nil)
(make-variable-buffer-local 'easel-export-target-html-path)

(defcustom easel-open-browser-when-start-watch t
  "To open web browser when set t.")

(defun easel--executable-path ()
  "Return `easel' command."
  (or (and easel-executable-bin (file-exists-p easel-executable-bin))
      "easel"))

;;;###autoload
(defun easel-insert-template ()
  "Inserte markdown leancanvas template."
  (interactive)
  (shell-command (format "%s init" (easel--executable-path)) (current-buffer)))

;;;###autoload
(defun easel-export-to-html (confirm-file-path)
  "Export lean canvas html.  Confirm file path if `CONFIRM-FILE-PATH' is t."
  (interactive "p")
  (when (or (null easel-export-target-html-path) (not (eq confirm-file-path 1)))
    (setq easel-export-target-html-path (read-file-name "Easel html export to: " )))

  (interactive "F")
  (let ((src-file-path buffer-file-name))
    (with-current-buffer (find-file-noselect easel-export-target-html-path)
      (erase-buffer)
      (insert (shell-command-to-string
               (format "%s write %s" (easel--executable-path) src-file-path)))
      (save-buffer))))

;;;###autoload
(defun easel-watch (file)
  "Launch easel server to watch `FILE'."
  (interactive "Peasel watch this file?: ")
  (when (eq file t)
    (setq file buffer-file-name))
  (when (and easel-target-file (string= easel-target-file file)))

  (setq easel-target-file (if (eq file t) buffer-file-name file))
  (prodigy-start-service
      (prodigy-find-service "easel"))
  (when easel-open-browser-when-start-watch
      (browse-url easel-server-url)))

;;;###autoload
(prodigy-define-service
  :name "easel"
  :command (lambda (&rest args) (easel--executable-path))
  :args (lambda (&rest args) (list "watch" easel-target-file)))

(provide 'easel)
;;; easel.el ends here
