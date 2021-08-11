;;; package --- Main init file
;;; Commentary:
;;; This is my init file

;;; Code:

(add-to-list 'load-path (concat user-emacs-directory "elisp"))

(require 'base)
(require 'base-theme)
(require 'base-extensions)
(require 'base-functions)
(require 'base-global-keys)
(require 'lsp)
(require 'lang-python)
(require 'lang-go)
(require 'lang-javascript)
(require 'lang-web)
(require 'lang-haskell-lsp)
(require 'lang-racket)
(require 'lang-c)
(require 'lang-lua)
(require 'lang-julia)
