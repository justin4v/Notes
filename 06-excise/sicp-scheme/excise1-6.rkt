#lang racket

;find the square root of x with the Newton mehthod
;(define (sqrt-itr gusess x)
;  (if (good-enough? guess x)
;      guess
;      (sqrt-itr (improve guess x) x)))

;good enough. attention that ? is part of procedure name
(define (good-enough? guess x)
  (< (abs-u (- x (square guess))) 0.001))

(define (abs-u x)
  (if (< x 0)
      (- x)
      x))

;square procedure
(define (square x) (* x x))

;core of Newton method. next guess is the avarage of guess and x/guess
(define (improve guess x)
  (/ (+ guess (/ x guess)) 2))

(define (sqrt-u x)
  (sqrt-itr x 1.0))

;new if by cond. it is not a special form but a ordinary form
(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
        (else else-clause)))

;interpreter will use applicative-order in ordinary procedure.
;so the (sqrt-itr (improve guess x) x) will be evaluate first when be passed to new-if
;so the interpreter will fall into unlimit loop
;(define (sqrt-itr guess x)
;  (new-if (good-enough? guess x)
;      guess
;      (sqrt-itr (improve guess x) x)))

(define (sqrt-itr guess x)
  (cond ((good-enough? guess x) guess)
      (else (sqrt-itr (improve guess x) x))))

;example
(sqrt-itr 1 2)
