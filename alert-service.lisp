(in-package #:scrap)

(defparameter *search-term* "maka paka")
(defvar *alert-service-timer* nil)

;;; TODO a way of generating 

(defun start-alert-service (&optional (delay 3600))
  (unless *alert-service-timer*
    (setf *alert-service-timer* (trivial-timers:make-timer (lambda () (funcall 'process-alert-service)))))

  (unless (trivial-timers:timer-scheduled-p *alert-service-timer*)
    (trivial-timers:schedule-timer *alert-service-timer* 0 :repeat-interval delay)))

(defun stop-alert-service ()
  (when (and *alert-service-timer*
             (trivial-timers:timer-scheduled-p *alert-service-timer*))
    (trivial-timers:unschedule-timer *alert-service-timer*)))

(defun alert-service-active-p ()
  (when (and *alert-service-timer*
             (trivial-timers:timer-scheduled-p *alert-service-timer*))
    t))



(defun process-alert-service ()
  (let* ((search (ignore-errors (fetch-oglaszamy24-dom *search-term*)))
         (ads (when search
                (list-ads search))))
    ;; TODO actual implementation
    ;; 1. cache results by ID or datetime or something to a hash table
    ;; 2. launch Pushover notification if new ads detected
    ))
