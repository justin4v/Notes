#lang racket

;tell if the interpreter use applicative-order or normal-order
(define (p) (p))
(define (test x y)
  (if (= x 0) 0 y))

(test 0 (p))

;applicative-order will evaludate every subexp. before next step until all exp. is primitive
;normal-order otherwise will not evaluate exp. until necessary.
;so the applicative-order interpreter will fall into unlimit loop when evaluate exp. '(p)' while normal-order will not. 