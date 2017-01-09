(require 'upe-constants)
(require 'upe-utils)

(defun use-package-ext-tripple (args f)
  (declare (indent 1))
  (apply f (pcase args
             (`((,repo . ,out) ,asyncp . ,_) (list repo out t))
             (`(,repo ,asyncp . ,_) (list repo nil t))
             (`((,repo . ,out) . ,_) (list repo out nil))
             (`(,repo) (list repo nil nil)))))

(defun use-package-normalize/:github (package-name-s keyword args)
  (when (> (length args) 2)
    (use-package-error ":github accepts no more then two args"))
  (use-package-ext-tripple args
    (lambda (repo out-folder asyncp)
      (list
       (if (cl-search "/" (symbol-name repo))
           (symbol-name repo)
         (format "%s/%s.el" repo package-name-s))
       (if out-folder out-folder use-package-sources-cache-folder)
       asyncp))))

(defun use-package-handler/:github (package-name-s keyword config rest state)
  (pcase-let* ((`(,repo ,output-path ,asyncp . ,_) config)
               (package-name (symbol-name package-name-s))
               (destination-folder (expand-file-name (concat output-path "/" package-name)
                                                     user-emacs-directory))
               (monkey (append `(:load-path ,(list destination-folder)) rest))
               (body (use-package-process-keywords package-name-s monkey state)))
    (use-package-concat
     `((if (file-exists-p ,destination-folder)
           (progn ,@body)
         (let ((git-clone-args (format "git@github.com:%s.git %s" ,repo ,destination-folder)))
           ,(if asyncp
                `(deferred:$
                   (deferred:process-shell "git" "clone" git-clone-args)
                   (deferred:nextc it (lambda (result) ,@body)))
              `(progn
                 (shell-command (format "git clone %s" git-clone-args))
                 ,@body))))))))

(setq use-package-keywords (upe--insert-after-kw :requires :github))

(provide 'upe-github)
