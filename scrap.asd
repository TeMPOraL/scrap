;;; scrap.asd

(asdf:defsystem #:scrap
  :serial t
  :long-name "Scrapper for random stuff."
  :author "Jacek Złydach"
  :version (:read-file-from "version.lisp" :at (1 2 2))
  :description "Scrapper for random web stuff."
                                        ; :long-description "todo"

  :license "MIT"
  :homepage "https://github.com/TeMPOraL/scrap"
  :bug-tracker "https://github.com/TeMPOraL/scrap/issues"
  :source-control (:git "https://github.com/TeMPOraL/scrap.git")
  :mailto "temporal.pl+scrap@gmail.com"

  :encoding :utf-8

  :depends-on (#:alexandria
               #:drakma
               #:cl-ppcre
               #:chtml-matcher
               #:cxml
               #:css-selectors)

  :components ((:file "package")
               (:file "version")

               (:file "utils")

               (:file "oglaszamy24")

               (:file "main")))
