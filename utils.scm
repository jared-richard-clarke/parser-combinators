(library (utils)
         (export empty?
                 identity
                 char-in?
                 symbol-in?
                 compose
                 assert-test)
         (import (rnrs))
         
         (define empty? null?)
         
         (define identity (lambda (x) x))

         (define element
           (lambda (test)
             (lambda (x xs)
               (let loop ([x x] [xs xs])
                 (cond
                   [(empty? xs) #f]
                   [(test x (car xs)) #t]
                   [else (loop x (cdr xs))])))))

         (define char-in?   (element char=?))        
         (define symbol-in? (element eq?))

         (define (compose . functions)
           (lambda (arg)
             (fold-right (lambda (function value)
                           (function value))
                         arg
                         functions)))

         (define-syntax assert-test
           (lambda (stx)
             (syntax-case stx ()
               [(_ compare x y)
                (syntax (let ([computed-x x]
                              [computed-y y])
                          (unless (compare computed-x computed-y)
                            (printf "Test failed:\nlhs: ~a -> ~a, rhs: ~a -> ~a\n"
                                    (quote x)
                                    x
                                    (quote y)
                                    y))))])))
         )
