#lang racket
(require images/icons/stickman 2htdp/image 2htdp/universe)

(define N 28)  ; frames pr second
(define height 128)
(define step-length (* 0.41 height))
(define step/frame (/ step-length N))

(define (render-man n)
  (define t (/ (remainder n N) N))
  (freeze (running-stickman-icon t #:height 128 
                                   #:head-color "white"
                                   #:arm-color  "gray"
                                   #:body-color "lightblue")))

(define men (for/vector ([n N]) (render-man n)))
(define (man n) (vector-ref men (remainder n N)))
(define background 
  (above (rectangle 800 (* 2 height) "solid" "white")
         (rectangle 800 (* 1 height) "solid" "darkgreen")))

(define (render n)
  (place-image (man n) (* n step/frame) (* 1.5 height) background))


(animate render)
