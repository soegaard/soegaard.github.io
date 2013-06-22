#lang scribble/manual
Title: Running Man
Date: 2013-06-21T12:38:51
Tags: animation, animate, running man, icons

@(require scribble/eval racket/sandbox)
@(require (for-label racket images/icons/stickman 2htdp/image 
                     (except-in racket/draw make-color make-pen)))
@(define my-eval (make-base-eval))

Have you ever noticed the little man in the bottom right corner of DrRacket?

At first sight he looks hand drawn, but the appearance deceives.
The little guy is in fact ray traced. Neil Toronto the man behind
the ray tracing code, was inspired by the animation of the main 
character in the Commodore 64 classic 
@hyperlink["http://en.wikipedia.org/wiki/Impossible_Mission"]{Impossible Mission}.

Buried in the documentation of the @racket[icons] library, one finds
the function @racket[running-stickman-icon]. The function can be used
to generate frames of a running man animation - it even allows us
to change colors and size of the running man.

The first parameter of @racket[running-stickman-icon] is the 
time, @racket[t], a number between 0 and 1. Let's see 10 frames
of the default running man.

@interaction[#:eval my-eval
(require images/icons/stickman)
(for/list ([t (in-range 0 1 1/10)])
  (running-stickman-icon t))]

The default man is a little small, but we can easily change both 
the size and the colors of the man.

@interaction[#:eval my-eval
(require images/icons/stickman)
(running-stickman-icon 0 #:height 128 
                         #:head-color "white"
                         #:arm-color  "gray"
                         #:body-color "lightblue")]

It is now easy to create an animation of the running man.
First we need a function @racket[render-man] that given a 
frame number will produce an image. Then the function @racket[animate] 
from @racket[2htdp/image] can be used to display the animation.

To get a fluent motion we will use @racket[N]@racket[=28] frames 
in one cycle of the animation. Frame 0, 28, 56 and so forth will
be the same. If @racket[n] is the frame number (of the animation), 
then @racket[(remainder n N)] 
is the frame number in the 0 to @racket[N-1] range. Divide by @racket[n]
to get the time @racket[t] in the interval @racket[[0,1]].

@racketblock[
(define N 28)
(define (render-man n)
  (define t (/ (remainder n N) N))
  (freeze (running-stickman-icon t #:height 128 
                                   #:head-color "white"
                                   #:arm-color  "gray"
                                   #:body-color "lightblue")))]

Since the result of @racket[running-stickman-icon] is a @racket[bitmap%]
object, we need to "@racket[freeze]" it in order to use it with @racket[2htdp/universe].

The running man is now ready for action:

@racketblock[
(require images/icons/stickman 2htdp/image 2htdp/universe)
(define N 28)
(define (render-man n) ...)
(animate render-man)]

Those of you who tried the above in 
@hyperlink["http://docs.racket-lang.org/drracket/index.html?q=drracket"]{DrRacket}
are probably not too impressed. 

Can you spot the problem?


The animation is slow and stutters. For each frame the ray tracer is activated
to produce an image. Since @racket[animate] shows 28 frames pr second, the
function @racket[render-man] is not allowed to use more than 1/28 second to
generate each image - and for large heights the ray tracer is not fast enough.

The solution is to prerender the images of the running man before starting
the animation. This way each image is generated only once.

@racketblock[
(require images/icons/stickman 2htdp/image 2htdp/universe)
(define N 28)
(define (render-man n) ...)
(define men (for/vector ([n N]) (render-man n)))
(define (man n) (vector-ref men (remainder n N)))
(animate man)]

@(require (except-in file/gif color?))
@(require images/icons/stickman
          (except-in racket/draw make-color make-pen) 2htdp/universe 
          racket/class racket/bytes 2htdp/image)
@(begin
   (define N 28)
   (define (render-man n)
     (define t (/ (remainder n N) N))
     (define man (running-stickman-icon 
                  t #:height 128 
                  #:head-color "white" 
                  #:arm-color "gray" 
                  #:body-color "lightblue"))
     ; man has a transparant background
     ; since gifs have no alpha channel, we make sure the background is white
     (define man/white (make-object bitmap% (image-width man) (image-height man)))
     (define dc (new bitmap-dc% [bitmap man/white]))
     (send dc set-background "white")
     (send dc clear)
     (send dc draw-bitmap man 0 0)
     man/white)
   (define men (for/vector ([n N]) (render-man n)))
   (define (man n) (vector-ref men (remainder n N)))
   (define port (open-output-file "running-man.gif" #:exists 'replace))
   (define-values (max-w max-h) 
     (for/fold ([w 1] [h 1]) ([m men])
       (values (max (image-width m) w) 
               (max (image-height m) h))))
   (define stream (gif-start port max-w max-h 0 #f))   
   (gif-add-loop-control stream 0) ; loop images
   (for ([m men])
     (define w (image-width m))
     (define h (image-height m))
     (define pixels (make-bytes (* 4 w h) 0))
     (send m get-argb-pixels 0 0 w h pixels) ; mutates pixels
     (define-values (bytes colormap transparent) (quantize pixels))
     (gif-add-image stream 0 0 w h #f colormap bytes))   
   (gif-end stream)
   (close-output-port port))

@image{running-man.gif}
