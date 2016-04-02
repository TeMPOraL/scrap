(in-package #:scrap)

(defun fix-drakma-output (output)
  "Takes `OUTPUT' from drakma:http-request and coerces it into a string."
  (if (stringp output)
      output
      (map 'string #'code-char output)))

(defun dom-element-attributes-to-kv-list (element)
  (let ((attributes (dom:attributes element)))
    (mapcar (lambda (attr) (list (dom:name attr) (dom:value attr)))
            (dom:items attributes))))

(defun pprint-dom-element (*standard-output* element)
  (pprint-logical-block (*standard-output* nil)
    (case (type-of element)             ;FIXME replace with dom:text-node-p
      (rune-dom::element
       (write-char #\<)
       (write-string (dom:tag-name element))
       (pprint-logical-block (*standard-output* (dom-element-attributes-to-kv-list element))
         (pprint-exit-if-list-exhausted)
         (loop (write-char #\Space)
            (destructuring-bind (name value)
                (pprint-pop)
              (write-string name)
              (write-string "=\"")
              (write-string value)
              (write-char #\")
              (pprint-exit-if-list-exhausted)
              (pprint-newline :fill))))
       (write-char #\>)
       (when-let ((child-nodes (coerce (dom:child-nodes element) 'list)))
         (pprint-indent :block 2)
         (pprint-newline :linear)

         (pprint-logical-block (*standard-output* child-nodes)
           (pprint-exit-if-list-exhausted)
           (loop (pprint-dom-element *standard-output* (pprint-pop))
              (pprint-exit-if-list-exhausted)
              (pprint-newline :fill))))
         
       (pprint-indent :block 0)
       (pprint-newline :linear)
       (write-string "</")
       (write-string (dom:tag-name element))
       (write-char #\>))
      (rune-dom::text
       (write-string "text"))
      (t (write-string "Unknown")))))

;;; copied from https://github.com/tshatrov/webgunk/blob/master/webgunk.lisp
(defun strip-whitespace (str)
  ;;remove initial whitespace
  (setf str (cl-ppcre:regex-replace "^\\s+" str ""))
  ;;remove trailing whitespace
  (setf str (cl-ppcre:regex-replace "\\s+$" str ""))
  
  ;;remove initial/trailing whitespace in multiline mode
  (setf str (cl-ppcre:regex-replace-all "(?m)^[^\\S\\r\\n]+|[^\\S\\r\\n]+$" str ""))
  (setf str (cl-ppcre:regex-replace-all "(?m)[^\\S\\r\\n]+\\r$" str (make-string 1 :initial-element #\Return)))
  
  ;;replace more than two whitespaces with one
  (setf str (cl-ppcre:regex-replace-all "[^\\S\\r\\n]{2,}" str " "))
  
  ;;remove solitary linebreaks
  (setf str (cl-ppcre:regex-replace-all "([^\\r\\n])(\\r\\n|\\n)([^\\r\\n])" str '(0 " " 2)))
  
  ;;replace more than one linebreak with one
  (setf str (cl-ppcre:regex-replace-all "(\\r\\n|\\n){2,}" str '(0)))
  str)

;;; copied from https://github.com/tshatrov/webgunk/blob/master/webgunk.lisp
(defun node-text (node &rest args &key test (strip-whitespace t))
  (let (values result)
    (when (or (not test) (funcall test node))
      (dom:do-node-list (node (dom:child-nodes node))
        (let ((val (case (dom:node-type node)
                     (:element (apply #'node-text node args))
                     (:text (dom:node-value node)))))
          (push val values))))
    (setf result (apply #'concatenate 'string (nreverse values)))
    (if strip-whitespace (strip-whitespace result) result)))
