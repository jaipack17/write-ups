<div align="center">
   <h1>Bézier Curves</h1>
   <p>Understanding the formation of Bézier Curves (using Linear Interpolation)</p>
</div>

# Table of Contents
* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Linear Interpolation](#linear-interpolation)
* Linear Bézier Curve
* Quadratic Bézier Curve
* Cubic Bézier Curve
* Bézier Curves with 'n' Control Points
* Resources

# Overview
Bézier curves are widely used by many mathematicians, software engineers, computer graphics engineers, designers and other professional individuals in their work. They are one of the most famous curves and their formation is immensely easy to understand for newbies. The curves, which are related to Bernstein polynomials, are named after French engineer Pierre Bézier, who used it in the 1960s for designing curves for the bodywork of Renault cars. The formation of Bézier curves is quite interesting. 

![bezier](https://raw.githubusercontent.com/jaipack17/write-ups/main/B%C3%A9zier%20Curves/assets/bezier.gif)

Bézier curves are formed using nested/multiple Linear Interpolations. Let's understand what a Linear Interpolation is, but before that here are some optional Prerequisites.

# Prerequisites

* Basic knowledge of algebra
* Basic knowledge of algebraic functions
* Basic knowledge of geometry and its terminologies 

# Linear Interpolation

Initially in this article, I introduced a new term for some of you, "Linear Interpolation". Linear Interpolation or in short lerp, is a mathematical method for finding way points on a straight ray, line segment or line. If two points are known, infinite points can be calculated on a straight path connected to these two points. We refer these 2 points as 'anchor points'. We'll see how Bézier curves make the use of Linear Interpolation.
