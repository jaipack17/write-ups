<div align="center">
     <h1>Optimizing 2D Curves</h1>
</div>
<hr/>

# Contents

* [Overview](#overview)
* [Eliminating Straight Lines](#eliminating-straight-lines)
* [Douglas Peucker Algorithm](#douglas-peucker-algorithm)

# Overview

When rendering curves on the screen, we use up a lot objects to cover up the spaces between and to connect points (lying on the curve) together. Sometimes if not always, we tend to use more objects than actually necessary, this can hurt performance and take up a lot of memory. In this write-up, I cover a few methods that can help reduce memory usage when dealing with curves. 

The techniques I'll be sharing are very beneficial for a number of situations. These include - drawing bezier curves, splines, optimizing drawing tools and much more. If you're dealing with such cases, stick around till the end.

Firstly, to answer an important question of "**Why?**". Let's say you create a drawing board/tool, audio visualizer or any other piece of work that requires you to render one or more curves on the screen. Maybe even update curves each frame (At 60 fps, updating them 60 times a second) or updating them every once in a while. With 'updating' I refer to the procedure of recalculating the curve and rendering it on the screen. If the curves are huge, or if there are too many curves, they are going to take up a lot of resources, especially memory. Updating them multiple times would also be a tedious task since there exist too many points on the curve to traverse through. Reducing the number of points when calculating a curve or after calculating a curve will make it easier and faster to traverse through but will also save memory. Hence the reason to why it is important to sneak in optimizations whereever possible and logical.

# Eliminating Straight Lines

Since we are calculating different points and connecting them with line segments to form curves, it is possible that some points lie on a straight line but use more line segments than required. Here's what the vague term "points lie on a straight line" refers to - In the image below, you can see 4 lines (in blue) passing through the points of the curve (in light red). These lines pass through multiple points on the curves.

<img src="https://user-images.githubusercontent.com/74130881/150629282-26e69b2a-8438-404c-a7bc-fd531b551dff.png" width="450px" />

If you are connecting each point with the point next to it, you may be using too many line segments to create the curve. It is possible in a lot of cases that some consecutively arranged points of a curve may all lie on 1 straight line i.e. this part of the curve is a straight line. So in the case of you connecting each consecutive point with a line segment, you will end up using more line segments than actually needed! If a set of consecutive points lie on the same line, can't we just connect the first and the last point in this sequence instead of connecting each point to the next? Well, yes!

<img src="https://user-images.githubusercontent.com/74130881/150629750-538e1002-53dc-428a-9068-19d4fc564689.png" width="550px" />

In the image above, A, B, C, D and E lie on the same line. Meaning, a line passes through all 5 of these points (marked in blue). Hence we can eliminate B, C and D and just connect AE with one line segment. Earlier we used eight line segments for this small curve, after eliminating unnecessary line segments, we create this curve with just five line segments. This isn't a very huge change, but helps a lot in certain cases and also when the curves consist of a large number of points. This technique reduces the amount of line segments you actually make use of but without having an impact on the resolution of the curve.

The implementation of this algorithm is rather easy. We can do this by traversing through each point of the curve, and then searching for the next point to connect with the initial one. Suppose we are at point A, we now start the search for the point we should connect with point A. We go to point B and we find that B lies on the same line as A. Note that two consecutive points considering that either one of them is an 'initial' point will always lie on the same line. We then go to point C and we find that C lies on the same line as A and B! So, we eliminate B and set the point we should connect to A as point C. Now we go to point D and we find out that D does not lie on the same line as A and C, this means we have successfully found the point we should connect with point A, which in our case is point C. We join point A and C and then continue the process starting from point C until the end of the curve.

Here's the implementation of this algorithm in Lua.

```lua
-- An array of points on the curve
local points = { ... }

local start = points[1]
local next = nil

-- Starting from the second index
for i = 2, #points do 
     -- If next does not exist, set next to the current point
     if not next then 
          next = points[i]
          i += 1
     end

     if points[i] then 
          local line = next - start

          -- If the current point lies on the line spanned by the vector
          if points[i]:Cross(line) == 0 then
               next = points[i]
          else 
               -- If not, draw the line segment, set start to next and next to nil.
               DrawLineSegment(start, next)
               start = next
               next = nil
          end
     end
end
```

You can apply this optimization after calculating the points and during the rendering process or directly when calculating the points of the curve. It is also worth noting that it may not always be the case that the points lie **exactly** on the same straight line thus giving not so interesting optimization results. To counter this problem, you could check the perpendicular distance between the point and the straight line you are checking for. If the distance is less than some threshold, you could say that 'the point lies on the line'. Also take a note that the larger this threshold, the lesser the resolution of the curve. And in my opinion, this method is the go-to method for eliminating straight lines. There is an edge case to the distance check. If a point is close to the line but isn't in the direction where `next - start` vector is pointing, then it's going to malform the curve. To fix this, you may want to also check the direction in which the point lies.

<img width="500px" src="https://user-images.githubusercontent.com/74130881/150632590-fc4e7fce-4a1e-4666-975b-b7fc014bf619.png" />

This technique will produce different results for different kinds of curves, for some curves there may not be much of a difference but for some it may be a drastic improvement. 

# Douglas Peucker Algorithm
