#lang scribble/manual
Title: Summer Project: Meta(font|post) in Racket
Date: 2013-06-21T12:38:51
Tags: graphics, hobby, metafont, metapost, tikz

@(require scribble/eval racket/sandbox)
@(require (for-label racket pict))
@(define my-eval (make-base-eval))
@(define tikz-url "http://www.texample.net/tikz/")
@(define metafont-url "http://en.wikipedia.org/wiki/Metafont")
@(define metapost-url "http://en.wikipedia.org/wiki/MetaPost")
@(define knuth-url "http://www-cs-faculty.stanford.edu/~uno/")
@(define hobby-url "http://ect.bell-labs.com/who/hobby/index.shtml")

The summer holiday is getting closer. This means there is time to focus on hacking.
Last year my summer project was to
implement a @hyperlink["http://docs.racket-lang.org/math/matrices.html?q=matrix"]{matrix}
library and a 
@hyperlink["http://docs.racket-lang.org/math/number-theory.html?q=matrix"]{number theory}
library.

This year I have decided to write a graphics library inspired by the approach taken by
@hyperlink[metafont-url]{Metafont}, @hyperlink[metapost-url]{Metapost} 
and @hyperlink[tikz-url]{Tikz}. The basic concept in these libraries is a @emph{path}.
The existing Racket library @racket[pict] on the other hand is based on @emph{pictures}.

Bezier curves will be used to draw the paths. Drawing a Bezier curve is straight forward;
the builtin graphics library, @racket[racket/draw] has support for this
in the form of
@hyperlink["http://docs.racket-lang.org/search/index.html?q=curve-to"]{curve-to}.

What is needed is convenient ways of @emph{specifying} and @emph{manipulating} paths.

The first problem will be this: Given points @emph{P0}, @emph{P3}, @emph{P6}, ..., @emph{Pn}.
Draw a "pretty" curve through these points. That is, determine which Bezier curves
is to be drawn between @emph{P0} and @emph{P3}, between @emph{P3} and @emph{P6} etc.

@hyperlink[hobby-url]{John D. Hobby} and @hyperlink[knuth-url]{Donald Knuth} introduced 
the algorithm now known as "Hobby's Algorithm" in Metafont to solve this problem. It is 
the central algorithm of the library.

The second problem is to introduce syntax for specifying paths. There is no doubt that
the popularity of MetaPost in TeX circles is the concise syntax - so I'll see how
much it makes sense to steal.

The third problem is to support for specifying points based on linear equations. Luckily the 
grunt works is already done - the matrix library contains equation solvers.

@;The shape of a Bezier curve from @emph{P0} to @emph{P3} is determined by two points, 
@;@emph{P1} and @emph{P2}, called @emph{control points}. So the problem boils down
@;to choosing the control points. Recently there have been quite a few blog posts
@;on how to draw Bezier curves (for example Jeremy Kun's the excellent 
@;@hyperlink["http://jeremykun.com/2013/05/11/bezier-curves-and-picasso/"]{Bezier Curves and Picasso}),
@;but they always omit advice on how to choose control points.

Breaking large project into chunks help tremendously. Just witness
how fast the number of completed Racket tasks went up on 
@hyperlink["http://rosettacode.org/wiki/Category:Racket"]{RosettaCode}.

@itemlist[#:style 'ordered
  @item{Draw a Bezier curve using @racket[racket/draw]}
  @item{Explain Hobby's algorithm}
  @item{Implement Hobby's algorithm}
  @item{Design syntax for paths}
  @item{Implement syntax for paths}
  @item{Document syntax for paths}
  @item{Predefinitions for standard paths}
  @item{Examples - inspration from the Metafontbook and Tikz}
  @item{Linear expressions and "linear variables"}
  @item{Syntax for linear expressions and linear variables.}
  @item{From fonts to paths}
  @item{Higher order path operations}
  @item{Bounding boxes for paths}
  @item{Intersections between curves}
  @item{Coloration of areas}
  @item{Bitmaps}
  @item{Relation to picts?}]
