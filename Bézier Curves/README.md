<div align="center">
   <h1>Bézier Curves</h1>
   <p>A cavernous dive into the world of Bézier Curves - The Fundamentals</p>
   <hr/>
</div>

# Table of Contents
* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Linear Interpolation](#linear-interpolation)
* [Linear Bézier Curve](#linear-bézier-curve)
* [Quadratic Bézier Curve](#quadratic-bézier-curves)
* [Cubic Bézier Curve](#cubic-bézier-curves)
* [Conclusion](#conclusion)
* [Resources](#resources)

# Overview
Bézier curves are widely used by many mathematicians, software engineers, computer graphics engineers, designers and other professional individuals in their work. They are one of the most famous curves and their formation is immensely easy to understand. The curves, which are related to Bernstein polynomials, are named after French engineer Pierre Bézier, who used it in the 1960s for designing curves for the bodywork of Renault cars. The formation of Bézier curves is quite interesting, and so we'll play around with them for a bit!

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

Consider a percentage value between 0 and 1 where 0.1 denotes 10%, 0.25 denotes 25%, 0.97 denotes 97% and so on. We use this percentage value to calculate a way point on the line segment. Example: let the percentage value be 0.5 (50%), using linear interpolation we'll be able to calculate the mid-point of the line segment.

Lets denote this percentage value by the letter 't' by standards. Here's a brief visualization of what I am up to:

![image](https://user-images.githubusercontent.com/74130881/134638261-f03c8be3-3d77-4b71-9e8e-94d38c9104ac.png)

We have a basic idea on how we'll get these points, lets write it in the form of an expression.

![formula](https://github.com/jaipack17/write-ups/blob/main/B%C3%A9zier%20Curves/assets/formula.JPG?raw=true)

Yep, it's that simple. So what's happening here? Here P0 and P1 are vector values that consist of x and y. Lets take an example. Let P0 be (0, 0) and P1 be (2, 2). We add the difference of the positions of P1 and P0, multiply it with t to get the t'th% vector position and add it to the position of P0. This is basically the unitary method! Lets take P0 as (0, 0) and P1 as (2,2), the same example we took earlier, and take t as 0.5 which essentially gives us the mid point of the line. Which you may already assume as (1, 1) right? Well lets find out.

![example](https://github.com/jaipack17/write-ups/blob/main/B%C3%A9zier%20Curves/assets/example.JPG?raw=true)

The difference of P0 and P1 is (2, 2), multiply (2, 2) with 0.5, which gives us (2 * 0.5, 2 * 0.5) which is (1, 1). Ultimately add this to P0 which gives us (0, 0) + (1, 1) = (1, 1). Amazing! We now have the mid point of the line. This should work in all cases as long as t = real number between 0 and 1! Ultimately, after simplying the above expression we can rewrite it as:

![final-formula](https://github.com/jaipack17/write-ups/blob/main/B%C3%A9zier%20Curves/assets/final.JPG?raw=true)

# Linear Bézier Curve

A Linear Bézier curve is not really a curve, but a straight line formed using the lerp function we talked about above. If we increase the value of t by some incrementation value up till 1 and draw a point, we'll notice that a line is formed between the two anchor points we took. Here's a visualization of the same:

![linear](https://github.com/jaipack17/write-ups/blob/main/B%C3%A9zier%20Curves/assets/linear.gif?raw=true)

The pseudocode for the above simulation is as follows:

```lua
p0 = (x, y);
p1 = (x, y);
t = 0;

function lerp(t)
   return (1 - t) * p0 + t * p1
end

for t until t == 1, increment by 0.01 do 
   point = lerp(t)
   drawPointAt(point)
end
```

In the above pseudocode, there is an increase in the value of t by 0.01. A point is then drawn at the lerped waypoint giving us the simulation of the gif. You may increment t by numbers like 0.1, 0.001 etc which'll give you different sorts of results, *depending on how low the value is, it hurts performance but gives a smoother line*

# Quadratic Bézier Curves

Previously we looked into Linear Bézier curves which basically gave us a line. Now to the curve, a quadratic curve looks something like the following:

![quad](https://developer.roblox.com/assets/blt6bac53c6c6f16b7b/Bezier2.gif)

We know about 'anchor points', now I'd like to introduce to you 'control points'. In the above gif P1 is the control point. Naturally the curve formed is inclined towards the control point. This control point influences the curvature of the line. A quadratic curve is formed by 2 anchor and 1 control points. Let's take a look at how quadratic curves are formed.

Here, you have two anchor points P0 and P1 and one control point C0. P0 and P1 are connected to C0 with a line segment.

![image](https://user-images.githubusercontent.com/74130881/134644549-54fc4fb2-670b-4eda-a1b7-b67d78e41467.png)

What if we lerp each line? We lerp line segment P0 - C0 and line segment C0 - P1. Here's a simulation of the lerps:

![ezgif com-gif-maker (5)](https://user-images.githubusercontent.com/74130881/134646038-37ed5564-eb69-406c-9890-9e6aa22a0b7c.gif)

Sick, but what do we do about these two lerps? Well... What if we connect each point we get on the two lines with a line segment, and then lerp this line segment with the same t value as the others? Woo, lets check it out.

![ezgif com-gif-maker (6)](https://user-images.githubusercontent.com/74130881/134646788-8505e8e9-5578-4494-a075-4d65088befd7.gif)

Notice the point Q0? If you haven't already, look at it closely, doesn't it move along a curvy imaginary path? Well, what if we compute its moving path!

![ezgif com-gif-maker (7)](https://user-images.githubusercontent.com/74130881/134647483-42c13365-ea29-4512-a1a1-8139ede5815f.gif)

It does infact form a curve! This is a quadratic bezier curve. Looking back to how we started, we lerped the first two line segments with t and lerped the segment connected to the two points we received after lerping, with the same percentage value (t). We can write it in the form of an expression and pseudocode as follows:

![image](https://user-images.githubusercontent.com/74130881/134648644-db3b4004-d376-432d-9f5d-e9f9d340d50b.png)

Which can further be written as

![image](https://user-images.githubusercontent.com/74130881/134649542-b3db54f5-bb04-4bcb-b54c-2edde0c6a57a.png)

```lua
p0 = (x, y);
p1 = (x, y);
c0 = (x, y)
t = 0;

function lerp(t)
   return (1 - t) * p0 + t * p1
end

for t until t == 1, increment by 0.01 do 
   point = lerp(lerp(p0, c0, t), lerp(c0, p1, t), t)
   drawPointAt(point)
end
```

P.S. *[media sources](https://www.youtube.com/watch?v=pnYccz1Ha34)*

# Cubic Bézier Curves

Cubic curves are very similar to Quadratic curves, but this time we use two control points C0 and C1 instead of 1. A cubic curve is a combination of two Quadratic curves. Let's take two anchor points P0 and P1, and two control points C0 and C1:

![image](https://user-images.githubusercontent.com/74130881/134650840-62566db7-22ee-4aa9-b11a-a282f8f957a4.png)

The blue arrows denote the direction of the base linear interpolations that will take place. If we make a quadratic curve out of P0, C0 and C1, and then make a quadratic curve out of C0, C1 and P1. We see two light green lines formed. We then lerp both of these lines and connect them with a line segment, then we lerp this line segment, which in the image below is dark green in color. The point we get is denoted by the peach color in the image below. That explaination was a bit janky but I hope you grasped something off of that.

![image](https://user-images.githubusercontent.com/74130881/134651989-19a2c602-705f-4101-a142-82bf77f32d8c.png)

Let's take a look at this in action:

![ezgif com-gif-maker (8)](https://user-images.githubusercontent.com/74130881/134652787-f192358e-7452-4c74-93da-68e2fccdf08b.gif)

We can thus write it in the form of expressions and pseudocode.

Lerping P0 - C0, C0 - C1 and C1 - P1

![image](https://user-images.githubusercontent.com/74130881/134653425-a743cc7d-630c-4ab8-8771-f8b893c82c96.png)

Forming 2 quadratic curve points:

![image](https://user-images.githubusercontent.com/74130881/134653753-c2871245-648d-423e-b93c-72f0594ec87f.png)

Forming the cubic curve way points using quad1 and quad2:

![image](https://user-images.githubusercontent.com/74130881/134653897-0b8a3f54-f376-48c0-92a5-fafe03c37a72.png)

Note that the value of t for all interpolations remain equal throughout. We can further simplify this into 1 single expression:

![image](https://user-images.githubusercontent.com/74130881/134654029-c47abfcf-3332-40f5-989c-25cc3a168b8e.png)

```lua
p0 = (x, y);
p1 = (x, y);
c0 = (x, y);
c1 = (x, y);
t = 0;

function lerp(t)
   return (1 - t) * p0 + t * p1
end

for t until t == 1, increment by 0.01 do 
   quad1 = lerp(lerp(p0, c0, t), lerp(c0, p1, t), t)
   quad2 = lerp(lerp(c0, c1, t), lerp(c1, p1, t), t)

   cubic = lerp(quad1, quad2, t)
   drawPointAt(cubic)
end
```

P.S. *[media sources](https://editor.p5js.org/ilmnarayana/full/_vyuj8rli)*

# Conclusion

This article was just a gist of Bézier Curves, how they are formed and the different kinds of curves. There are endless possibilities offered by these curves. You can have infinite amount of control points spread across a plane! Beautiful curves and art using these methods can be formed. Here's an amazing simulation I found, [Synthwave Visualizer by Prof Sears](https://editor.p5js.org/Prof-Sears/full/3zStiATFL)

There's a lot you can explore ahead but we'll end this here, I have listed some helpful resources below, do check them out. 
Thanks for reading.

# Resources

[Wiki](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) <br/>
[Bézier Curves by Guidev](https://www.youtube.com/watch?v=pnYccz1Ha34&ab_channel=Guidev) <br/>
[The Beauty of Bézier Curves by Freya Holmér](https://www.youtube.com/watch?v=aVwxzDHniEw&ab_channel=FreyaHolm%C3%A9r) <br/>
[Bézier Curves by Daniel Shiffman](https://www.youtube.com/watch?v=enNfb6p3j_g) <br/>
[Sandbox - desmos](https://www.desmos.com/calculator/cahqdxeshd)
