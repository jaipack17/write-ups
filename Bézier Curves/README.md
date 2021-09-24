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
* Understanding of Coordinates and Vectors 
* Vector math operations

# Linear Interpolation

Initially in this article, I introduced a new term for some of you, "Linear Interpolation". Linear Interpolation or in short lerp, is a mathematical method for finding way points on a straight ray, line segment or line. If two points are known, infinite points can be calculated on a straight path connected to these two points. We refer these 2 points as 'anchor points'. We'll see how Bézier curves make the use of Linear Interpolation.

Suppose you have a line segment with two endpoints P0 and P1. How would you go about finding way points on this line segment? Here's where the concept of linear interpolation kicks in.

![line-segment](https://github.com/jaipack17/write-ups/blob/main/B%C3%A9zier%20Curves/assets/Capture.JPG?raw=true)

Consider a percentage value between 0 and 1 where 0.1 denotes 10%, 0.25 denotes 25%, 0.97 denotes 97% and so on. We use this percentage value to calculate a way point on the line segment. Example: let the percentage value be 0.5 (50%), using linear interpolation we'll be able to calculate the mid-point of the line segment.

Lets denote this percentage value by the letter 't' by standards. Here's a brief visualization of what I am up to:

![image](https://user-images.githubusercontent.com/74130881/134638261-f03c8be3-3d77-4b71-9e8e-94d38c9104ac.png)

We have a basic idea on how we'll get these points, lets write it in the form of an expression.

![formula](https://github.com/jaipack17/write-ups/blob/main/B%C3%A9zier%20Curves/assets/formula.JPG?raw=true)

Yep, it's that simple. So what's happening here? Here P0 and P1 are vector values that consist of x and y. Lets take an example. Let P0 be (0, 0) and P1 be (2, 2). We add the difference of the positions of P1 and P0, multiply it with t to get the t'th% vector position and add it to the position of P0. This is basically the unitary method! Lets take P0 as (0, 0) and P1 as (2,2), the same example we took earlier, and take t as 0.5 which essentially gives us the mid point of the line. Which you may already assume as (1, 1) right? Well lets find out.
