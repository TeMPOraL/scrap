(in-package #:scrap)

(defparameter *oglaszamy24-search-url* "http://www.oglaszamy24.pl/ogloszenia/")

(defun fetch-oglaszamy24-raw-results (search)
  (drakma:http-request *oglaszamy24-search-url*
                       :method :POST
                       :external-format-out :UTF-8
                       :parameters `(("keyword" . ,search))))

(defun fetch-oglaszamy24-dom (search)
  (chtml:parse (fetch-oglaszamy24-raw-results search)
               (cxml-dom:make-dom-builder)))

(defun list-ads (dom)
  (css:query "")
  )

(defun fetch-oglaszamy24-results (search)
  
)
