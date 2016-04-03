(in-package #:scrap)

(defvar *acceptor* nil)

(hunchentoot:define-easy-handler (o24-rss :uri "/o24-rss") (search)
  (setf (hunchentoot:content-type*) "text/xml")
  (with-output-to-string (stream)
    (ads-to-rss (fetch-oglaszamy24-results search) :stream stream)))

(defun start-webservice (&key (port 8123))
  (setf *acceptor* (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port port))))

(defun stop-webservice ()
  (hunchentoot:stop *acceptor* :soft t))
