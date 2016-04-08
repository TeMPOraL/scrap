(in-package #:scrap)

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
    (values t TODO)))
