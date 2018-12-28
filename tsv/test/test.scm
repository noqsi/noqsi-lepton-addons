(add-to-load-path ".")

(use-modules (noqsi tsv))
(use-modules (ice-9 format))

(define expected  '(
	("ichi") 
	("ni") 
	("one fish" "two fish") 
	("red fish" "blue fish"))
)

(define test (tsv-data "test"))

(if (not (equal? expected test)) (begin
	(format #t
		"Expected\n~s\ngot\n~s\n"
		expected
		test
	)
	(primitive-exit 1)
))