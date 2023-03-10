;; === UNDER HEAVY CONSTRUCTION ===

(library (parsers)
         (export character
                 any-character
                 digit
                 digits
                 letter
                 letters
                 upper-case
                 lower-case
                 alpha-num
                 one-of
                 none-of
                 space
                 spaces
                 skip-spaces
                 new-line
                 crlf
                 tab
                 punctuation
                 punctuation-ascii
                 trim-left
                 trim-right
                 trim
                 text)
         (import (rnrs)
                 (combinators)
                 (utils))

         ;; === parsers ===

         (define character
           (lambda (x)
             (satisfy (lambda (y) (char=? x y)))))

         (define any-character
           (satisfy (lambda (x) #t)))

         (define digit 
           (satisfy char-numeric?))

         (define digits (many-1 digit))

         (define letter
           (satisfy char-alphabetic?))

         (define letters (many-1 letter))

         (define upper-case
           (satisfy char-upper-case?))

         (define lower-case
           (satisfy char-lower-case?))

         (define alpha-num
           (or-else letter digit))

         (define one-of
           (lambda (txt)
             (let ([xs (string->list txt)])
               (satisfy (lambda (x) (char-in? x xs))))))

         (define none-of
           (lambda (txt)
             (let ([xs (string->list txt)])
               (satisfy (lambda (x) (not (char-in? x xs)))))))

         (define space 
           (satisfy char-whitespace?))

         (define spaces (many space))

         (define skip-spaces (skip-many space))
         
         (define new-line (character #\newline))
         
         (define crlf
           (right (character #\return) new-line))
         
         (define tab (character #\tab))
         
         ;; Finds all punctuation as defined by Unicode.
         (define punctuation
           (satisfy (lambda (x)
                      (let ([category    (char-general-category x)]
                            [categories '(Po Ps Pe Pi Pf Pd Pc)])
                        (symbol-in? category categories)))))

         ;; Finds all punctuation as defined by ASCII. Subsumed by Unicode.
         (define punctuation-ascii
           (satisfy (let ([ascii (string->list "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~")])
                      (lambda (x) 
                        (char-in? x ascii)))))

         (define trim-left
           (lambda (px)
             (right skip-spaces px)))

         (define trim-right
           (lambda (px)
             (left px skip-spaces)))

         (define trim
           (lambda (px)
             (between skip-spaces px skip-spaces)))

         (define text
           (lambda (txt)
             (let ([parser (apply sequence (map character (string->list txt)))])
               (fmap list->string parser))))
         
         )
