(in-package #:scrap)

;;; TODO move all to #:scrap/ogloszenia24

(defparameter *oglaszamy24-search-url* "http://www.oglaszamy24.pl/ogloszenia/")

(defclass ad ()
  ((title :initarg :title
          :initform ""
          :accessor title)
   (url :initarg :url
        :initform nil
        :accessor url)
   (summary :initarg :summary
            :initform ""
            :accessor summary)
   (date :initarg :date
         :initform nil
         :accessor date)
   (price :initarg :price
          :initform nil
          :accessor price)))

(defun fetch-oglaszamy24-raw-results (search)
  (drakma:http-request *oglaszamy24-search-url*
                       :method :POST
                       :external-format-in :ISO-8859-2
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

    (make-instance 'ad
                   :title (node-text ad-title-node)
                   :url (dom:get-attribute ad-title-node "href")
                   :summary (node-text ad-description-node)
                   :date (when ad-date-node (node-text ad-date-node))
                   :price (when ad-price-node (node-text ad-price-node)))))

(defmethod print-object ((ad ad) stream)
  (print-unreadable-object (ad stream :type t :identity t)
    (with-slots (title date price) ad
      (format stream "~A -- ~A ~A" title date price))))

(defun process-ads (ad-node-list)
  (mapcar #'process-ad ad-node-list))

(defun list-ads (dom)
  (process-ads (css:query "div.o_single_box" dom)))

(defun fetch-oglaszamy24-results (search)
  (list-ads (fetch-oglaszamy24-dom search)))

(defun ads-to-rss (ads &key (stream *standard-output*) (encoding "utf-8"))
  (xml-emitter:with-rss2 (stream :encoding encoding)
    (xml-emitter:rss-channel-header "Some RSS" "http://example.com")
    (mapc (lambda (item)
            (xml-emitter:rss-item (title item)
                                  :link (url item)
                                  :description (summary item)))
          ads)))
