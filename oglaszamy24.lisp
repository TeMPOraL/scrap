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
        (ad-description-node (css:query1 "div.o_single_box > div:first-child > div:nth-child(4) > div:nth-child(4)" ad))
        (ad-date-node (first (css:query "div.o_single_box > div:first-child > div:nth-child(4) > div:nth-child(6) strong" ad)))
        (ad-price-node (second (css:query "div.o_single_box > div:first-child > div:nth-child(4) > div:nth-child(6) strong" ad))))

    (list (cons :title (node-text ad-title-node))
          (cons :url (dom:get-attribute ad-title-node "href"))
          (cons :content (node-text ad-description-node))
          (cons :date (when ad-date-node (node-text ad-date-node)))
          (cons :price (when ad-price-node (node-text ad-price-node))))))

(defun process-ads (ad-node-list)
  (mapcar #'process-ad ad-node-list))

(defun list-ads (dom)
  (process-ads (css:query "div.o_single_box" dom)))

(defun fetch-oglaszamy24-results (search)
  (list-ads (fetch-oglaszamy24-dom search)))
