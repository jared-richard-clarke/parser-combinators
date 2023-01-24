(import (rnrs)
        (utils))

;; === UNDER HEAVY CONSTRUCTION ===

;; A parser combinator library is a functional approach to building recursive descent parsers.
;; Basic functions implement parsers, whereas higher-order functions (combinators) implement
;; grammar constructions such as choice, sequencing, and repetition.
;;
;; (parser (list char)) -> (list) | (list any (list char))

;; === base ===

(define parse
  (lambda (parser text)
    (parser (string->list text))))

(define item
  (lambda (x)
    (if (empty? x)
        x
        (list (car x) (cdr x)))))

;; === monad ====

;; Also named "unit".
(define return
  (lambda (x)
    (lambda (input)
      (list x input))))

;; Also named ">>=".
;; Integrates the sequencing of parsers with the processing of their results.
(define bind
  (lambda (px f)
    (lambda (input)
      (let ([x (px input)])
        (if (empty? x)
            x
            ((f (car x)) (cadr x)))))))

;; Also named "empty".
(define zero
  (lambda ()
    (lambda input '())))

;; === functor ===

(define map-f
  (lambda (f px)
    (bind px (lambda (x)
               (return (f x))))))

;; === applicative ===

(define apply-p
  (lambda (pf px)
    (bind pf (lambda (f)
               (map-f f px)))))

;; (define apply-p
;;   (lambda (pf px)
;;     (bind pf (lambda (f)
;;                (bind px (lambda (x)
;;                           (return (f x))))))))

;; === satisfy ===

(define satisfy
  (lambda (predicate)
    (bind item (lambda (x)
                 (if (predicate x)
                     (return x)
                     (zero))))))

;; === choices ===

(define or-else
  (lambda (px py)
    (lambda (input)
      (let ([x (px input)])
        (if (empty? x)
            (py input)
            x)))))

(define choice
  (lambda (parsers)
    (fold-left or-else (car parsers) (cdr parsers))))

;; Applies parser px. If px fails, returns the value y.
(define option
  (lambda (px y)
    (or-else px (return y))))

;; Fails if parser px fails. Otherwise discards result and continues parsing.
(define optional
  (lambda (px)
    (or-else (bind px (lambda (x)
                        (return '())))
             (return '()))))

;; Also named ".>>", parses two values and discards the right.
(define left
  (lambda (px py)
    (map-f (lambda (xy)
             (let ([x (car xy)]
                   [y (cdr xy)])
               x))
           (and-then px py))))

;; Also named ">>.", parses two values and discards the left.
(define right
  (lambda (px py)
    (map-f (lambda (xy)
             (let ([x (car xy)]
                   [y (cdr xy)])
               y))
           (and-then px py))))

;; Parses three values, and, if successful, discards the left and the right values.
(define between
  (lambda (px py pz)
    (left (right px py) pz)))

;; === sequences ===

(define and-then
  (lambda (px py)
    (bind px (lambda (x)
               (bind py (lambda (y)
                          (return (cons x y))))))))

(define sequence
  (lambda (parsers)
    (fold-right and-then (return '()) parsers)))

(define many
  (lambda (px)
    (or-else (bind px (lambda (x)
                        (bind (many px) (lambda (xs)
                                          (return (cons x xs))))))
             (return '()))))

(define many-1
  (lambda (px)
    (bind px (lambda (x)
               (bind (many px) (lambda (xs)
                                 (return (cons x xs))))))))

;; === parsers ===

(define character
  (lambda (x)
    (satisfy (lambda (y) (char=? x y)))))

(define digit 
  (satisfy char-numeric?))

(define letter
  (satisfy char-alphabetic?))

(define space 
  (satisfy char-whitespace?))
