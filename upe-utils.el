(defun upe--insert-after (list elem insert-elem)
  "Insert `insert-elem' after `elem' in the provided `list'"
  (cond ((eq nil list) (list insert-elem))
        ((eq elem (car list)) (cons elem (cons insert-elem (cdr list))))
        (t (cons (car list) (insert-after (cdr list) elem insert-elem)))))

(defun upe--insert-after-kw (mark-kw new-kw)
  (insert-after use-package-keywords mark-kw new-kw))

(provide 'upe-utils)
