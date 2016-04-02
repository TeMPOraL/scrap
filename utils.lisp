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
