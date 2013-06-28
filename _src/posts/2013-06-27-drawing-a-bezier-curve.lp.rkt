#lang scribble/lp

@(require (for-label racket/draw racket))

This blog post shows to use the @racketmodname[racket/draw] library
to draw Bezier curves.

A Bezier curve connects two points, so we need a way to represent points.

@chunk[<pt-definition> (struct pt (x y))]

A Bezier curve from @racket[p0] to @racket[p3] with control points 
@racket[p1] and @racket[p2] is represented by a @racket[bez] structure:

@chunk[<bez-definition> (struct bez (p0 p1 p2 p3))]
The curve leaves @racket[p0] in the direction towards @racket[p1].
The curve approaces @racket[p3] in the direction from @racket[p2].

Given these structure definitions we can now represent Picasso's Dachshund
(see @hyperlink["http://jeremykun.com/2013/05/11/bezier-curves-and-picasso/"]{Jeremy Kun's Blog}).

@chunk[<dachshund>
(define dachshund
  (list ; Picasso's Dachshund (See Jeremy Kun's blog)
   (bez (pt 180 280) (pt 183 263) (pt 186 256) (pt 189 244)) ; front leg
   (bez (pt 191 244) (pt 290 244) (pt 300 230) (pt 339 245)) ; tummy
   (bez (pt 340 246) (pt 350 290) (pt 360 300) (pt 355 210)) ; back leg
   (bez (pt 353 210) (pt 370 207) (pt 380 196) (pt 375 193)) ; tail
   (bez (pt 375 193) (pt 310 220) (pt 190 220) (pt 164 205)) ; back
   (bez (pt 164 205) (pt 135 194) (pt 135 265) (pt 153 275)) ; ear start
   (bez (pt 153 275) (pt 168 275) (pt 170 180) (pt 150 190)) ; ear end + head
   (bez (pt 149 190) (pt 122 214) (pt 142 204) (pt  85 240)) ; nose bridge
   (bez (pt  86 240) (pt 100 247) (pt 125 233) (pt 140 238)))) ; mouth
]

The @racketmodname[racket/draw] library represents Bezier curves (or rather 
zero or more closed subpaths and one open subpath) as @racket[dc-path%] objects.
The function @racket[bez->dc-path] converts the representation of a Bezier curve 
from a @racket[bez] structure into @racket[dc-path%].

@chunk[<conversion>
(define (bez->dc-path b)
  (match-define (bez (pt x0 y0) (pt x1 y1) (pt x2 y2) (pt x3 y3)) b)
  (define p (new dc-path%))
  (send p move-to x0 y0)
  (send p curve-to x1 y1 x2 y2 x3 y3)
  p)]

It is now trivial to define a function, that draws a Bezier curve
using a given drawing context, @racket[dc]:

@chunk[<draw-bez>
(define (draw-bez dc b)
  (send dc draw-path (bez->dc-path b)))]

The dachshund is drawn piece by piece:

@chunk[<draw-dachshund>
(define (draw-dachshund dc)
  (for ([b dachshund])
    (draw-bez dc b)))]

Using drawing contexts allow to use the same @racket[draw-dachshund] function
to draw the dachshund on pdfs, bitmaps, and, more. Let's draw the dachshund
on a bitmap.

@chunk[<example>
(define bm (make-object bitmap% 400 100))
(define dc (new bitmap-dc% [bitmap bm]))
(send dc set-smoothing 'smoothed)
(send dc set-pen "red" 1 'solid)
(send dc translate 0 -185)
(draw-dachshund dc)
bm]

To run the code in this blog post, the pieces must be assembled in this order.

@chunk[<*>
(require racket racket/draw)
(provide bm)
<pt-definition>
<bez-definition>
<dachshund>
<conversion>
<draw-bez>
<draw-dachshund>
<example>]
