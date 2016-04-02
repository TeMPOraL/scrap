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

(defun process-ad (ad)
  (let ((ad-title-node (css:query1 "a.o_title" ad))
        (ad-description-node (css:query1 "div.o_single_box > div:first-child > div:nth-child(4) > div:nth-child(4)" ad)))

    (list (node-text ad-title-node)
          (node-text ad-description-node))))

(defun process-ads (ad-node-list)
  (mapcar #'process-ad ad-node-list))

(defun list-ads (dom)
  (process-ads (css:query "div.o_single_box" dom)))

(defun fetch-oglaszamy24-results (search)
  (list-ads (fetch-oglaszamy24-dom search)))
