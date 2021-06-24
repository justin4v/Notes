;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname excise1-3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;Define a procedure that takes three numbers as arguments
;and returns the sum of the squares of the two larger numbers.
(define (square x) (* x x))

(define (sum-of-square x y z)
  (+ (square x) (square y) (square z)))

(define (smaller x y)
  (if (< x y) x y))

(define (smallest x y z)
  (smaller (smaller x y) z))

;test
;(smallest 7 5 3)

(define (square-two-larger x y z)
  (- (sum-of-square x y z) (square (smallest x y z))))

(square-two-larger 1 2 3)


