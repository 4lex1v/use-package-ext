(require 'ert)

(ert-deftest upe--insert-after-spec ()
  "Tests the correct insertion point of `upe--insert-after'"

  ;; Test insertion into empty list
  (should (equal '(:one) (upe--insert-after '() :one :one)))

  ;; Test insertion into non-empty list with existing element
  (let ((kw-test-list '(:one :three)))
    (should (equal '(:one :two :three) (upe--insert-after kw-test-list :one :two )))
    (let ((tmp (upe--insert-after kw-test-list :three :four)))
      (should (equal '(:one :three :four) tmp))
      (should (equal '(:one :three :four :five) (upe--insert-after tmp :four :five)))))

  ;; Test insert after non-existing element (should be the last)
  (should (equal '(:one :three) (upe--insert-after '(:one) :two :three))))


