(require 'use-package)
(require 'async)

(defvar use-package-sources-cache-folder
  (expand-file-name ".cached-packages" user-emacs-directory)
  "Folder in which all source downloaded by use-package are stored")

(defun insert-after (list elem insert-elem)
  "Insert `insert-elem' after `elem' in the provided `list'"
  (cond ((eq nil list) (list insert-elem))
        ((eq elem (car list)) (cons elem (cons insert-elem (cdr list))))
        (t (cons (car list) (insert-after (cdr list) elem insert-elem)))))

(defun use-package-normalize/:github (package-name keyword args)
  (use-package-only-one (symbol-name keyword) args
    (lambda (label arg) arg)))

(defun use-package-handler/:github (package-name-s keyword source-type-arg rest state)
  (let* ((body (use-package-process-keywords package-name-s rest state))
         (package-name (symbol-name package-name-s))
         (path-in-cache-folder (expand-file-name package-name use-package-sources-cache-folder)))
    (use-package-concat
     `((if (file-exists-p ,path-in-cache-folder)
           (progn
             (add-to-list 'load-path ,path-in-cache-folder)
             ,@body)
         ,(let ((command (format "git clone git@github.com:%s/%s.git %s"
                                 source-type-arg
                                 package-name
                                 (expand-file-name package-name use-package-sources-cache-folder))))
            `(async-start
              (lambda () (shell-command ,command))
              (lambda (result) ,@body))))))))

(setq use-package-keywords (insert-after use-package-keywords :requires :github))

(provide 'use-package-sources)
