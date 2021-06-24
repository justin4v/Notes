;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname excise1-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
; primative data
;10
;(+ 5 3 4)
;(- 9 1)
;(/ 6 2)
;(+ (* 2 4)(- 4 6))

(define a 3)
(define b (+ a 1))
a
b
;(+ a b (* a b))
;(= a b)
;(if (and (> b a) (< b (* a b)))
;    b
;    a)
(cond ((= a 3) 6)
      ((= b 4) (+ 6 7 a))
      (else 25))
;(+ 2 (if (> b a) b  a))
;
;(* (cond ((> a b) a)
;         ((< a b) b)
;         (else -1))
;   (+ a 1))