;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname excise1-4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;Observe that our model of evaluation allows
;for combinations whose operators are compound expres-sions.
;Use this observation to describe the behavior of the following procedure

;实际上是 high-order fanction 返回函数的高级函数
(define (abs-n b)
  (if (> b 0)  + -))

(define (a-plus-abs-b a b)
  ((abs-n b) a b))

(a-plus-abs-b 1 -2)