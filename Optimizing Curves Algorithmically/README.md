> # Incomplete

<div align="center">
     <h1>Optimizing Curves Algorithmically</h1>
     <p>A few techniques and algorithms for curve simplification</p>
</div>
<hr/>

# Contents

* [Overview](#overview)
* [Eliminating Straight Lines](#eliminating-straight-lines)
* [Douglas-Peucker Algorithm](#douglas-peucker-algorithm)
* [Douglas-Peucker Algorithm on Loops and Polygons](#douglas-peucker-algorithm-on-loops-and-polygons)
* [Visvalingam-Whyatt Algorithm](#visvalingam-whyatt-algorithm)
* [Conclusion](#conclusion)

# Overview

A lot of situations arise when you have to make the use of curves algorithmically in game development, maybe curved paths for roads, generative art, procedural animations, to generate topological data etc. But, when rendering curves on the screen, we use up a lot objects to cover up the spaces between and to connect points (lying on the curve) together. Sometimes if not always, we tend to use more objects than actually necessary, this can hurt performance and take up a lot of memory. In this write-up, I cover a few methods that can help reduce memory usage when dealing with curves. 

The techniques I'll be sharing are very beneficial for a number of situations. These include - drawing bezier curves, splines, optimizing drawing tools and much more. If you're dealing with such cases, stick around till the end.

Firstly, to answer an important question of "**Why?**". Let's say you create a drawing board/tool, audio visualizer or any other piece of work that requires you to render one or more curves on the screen. Maybe even update curves each frame (At 60 fps, updating them 60 times a second) or updating them every once in a while. With 'updating' I refer to the procedure of recalculating the curve and rendering it on the screen. If the curves are huge, or if there are too many curves, they are going to take up a lot of resources, especially memory. Updating them multiple times would also be a tedious task since there exist too many points on the curve to traverse through. Reducing the number of points when calculating a curve or after calculating a curve will make it easier and faster to traverse through but will also save memory. Hence the reason to why it is important to sneak in optimizations whereever possible and logical.

# Eliminating Straight Lines

Since we are calculating different points and connecting them with line segments to form curves, it is possible that some points lie on a straight line but use more line segments than required. Here's what the vague term "points lie on a straight line" refers to - In the image below, you can see 4 lines (in blue) passing through the points of the curve (in light red). These lines pass through multiple points on the curves.

<img src="https://user-images.githubusercontent.com/74130881/150629282-26e69b2a-8438-404c-a7bc-fd531b551dff.png" width="450px" />

If you are connecting each point with the point next to it, you may be using too many line segments to create the curve. It is possible in a lot of cases that some consecutively arranged points of a curve may all lie on 1 straight line i.e. this part of the curve is a straight line. So in the case of you connecting each consecutive point with a line segment, you will end up using more line segments than actually needed! If a set of consecutive points lie on the same line, can't we just connect the first and the last point in this sequence instead of connecting each point to the next? Well, yes!

<img src="https://user-images.githubusercontent.com/74130881/150629750-538e1002-53dc-428a-9068-19d4fc564689.png" width="550px" />

In the image above, A, B, C, D and E lie on the same line. Meaning, a line passes through all 5 of these points (marked in blue). Hence we can eliminate B, C and D and just connect AE with one line segment. Earlier we used eight line segments for this small curve, after eliminating unnecessary line segments, we create this curve with just five line segments. This isn't a very huge change, but helps a lot in certain cases and also when the curves consist of a large number of points. This technique reduces the amount of line segments you actually make use of but without having an impact on the resolution of the curve.

The implementation of this algorithm is rather easy. We can do this by traversing through each point of the curve, and then searching for the next point to connect with the initial one. Suppose we are at point A, we now start the search for the point we should connect with point A. We go to point B and we find that B lies on the same line as A. Note that two consecutive points considering that either one of them is an 'initial' point will always lie on the same line. We then go to point C and we find that C lies on the same line as A and B! So, we eliminate B and set the point we should connect to A as point C. Now we go to point D and we find out that D does not lie on the same line as A and C, this means we have successfully found the point we should connect with point A, which in our case is point C. We join point A and C and then continue the process starting from point C until the end of the curve.

Here's the implementation of this algorithm.

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
               if i == #points then 
                    DrawLineSegment(start, next)
                    break
               end
          else 
               -- If not, draw the line segment, set start to next and next to nil.
               DrawLineSegment(start, next)
               start = next
               next = nil
          end
     end
end
```

You can apply this optimization after calculating the points and during the rendering process or directly when calculating the points of the curve. It is also worth noting that it may not always be the case that the points lie **exactly** on the same straight line thus giving not so interesting optimization results. To counter this problem, you could check the perpendicular distance between the point and the straight line you are checking for. If the distance is less than some threshold, you could say that 'the point lies on the line'. Also take a note that the larger this threshold, the lesser the resolution of the curve. This is somewhat similar to how the Douglas Peucker Algorithm works. And in my opinion, this method is the go-to method for eliminating straight lines. There is an edge case to the distance check. If a point is close to the line but isn't in the direction where `next - start` vector is pointing, then it's going to malform the curve. To fix this, you may want to also check the direction in which the point lies.

<img width="500px" src="https://user-images.githubusercontent.com/74130881/150632590-fc4e7fce-4a1e-4666-975b-b7fc014bf619.png" />

This technique will produce different results for different kinds of curves, for some curves there may not be much of a difference but for some it may be a drastic improvement. 

# Douglas-Peucker Algorithm

The Ramer Douglas Peucker algorithm is one of the most famous algorithms used for simplifying curves. The idea is similar to what we read above, this algorithm doesn't just look for straight lines but works to use lesser amount of line segments for the whole curve. This algorithm is pretty effecient besides a few edge cases that we saw earlier. 

<img width="500px" src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/RDP%2C_varying_epsilon.gif/330px-RDP%2C_varying_epsilon.gif" />

The idea is to reduce the amount of points used to draw the curve by filtering out the points we need to 'keep' for a simplified curve. First we form a line segment, this line segment is always the segment connecting the first and the last point of the curve, and lets call this line segment 'Q'. We can mark these two end-points to be kept for the simplified curve. We then define an epsilon or a small threshold. The greater this threshold, the lesser the resoluton of the curve or in other words the lesser the amount of points used for the curve. We then find the point on the curve that is the farthest from line segment Q, lets call this point A. 

If the distance between point A and line segment Q is less than our epsilon, discard it! If not, mark it as kept and then connect the start and end of the curve to point A. This makes the meaning of an epsilon much clearer. 

We then check for the farthest point from the two line segments (start-A and A-end), note that the farthest point should always lie inside the bounds of the line segment, check if the distances between the farthest points and the line segments are greater than epsilon, if yes then keep them else discard them! This recursively goes on until there are no points left to check for. 

<img width="500px" src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Douglas-Peucker_animated.gif/330px-Douglas-Peucker_animated.gif" />

Now for the implementation, we'll recursively call a function to get the farthest point between two bounds (a line segment), compare it with the epsilon, mark it as kept (by inserting it into a table), connecting it with our end points and running these checks again and again until there are no points left to check for.

```lua
-- An array of points on the curve
local points = { ... }

-- The points of the curve we need to keep after simplification i.e. the points of the simplified curve
local simplifiedCurve = {}

-- a and b are the end-points of the line segment.
-- Calculate the distance between line segment ab and the point
local function CalculateDistance(point: Vector2, a: Vector2, b: Vector2) : number
	local q = point - a
	local p = (b - a).Unit
	p *= p:Dot(q)

	return (point - (a + p)).Magnitude
end

-- Get furthest point between a and b from the line segment connecting a and b
-- a and b are the indices of the end points in the allPoints array
-- Returns the index of the farthest point
local function GetFarthestPoint(allPoints, a: number, b: number) : number
     local maxDistance = nil
     local farthestPoint = -1
     local startPoint = allPoints[a]
     local endPoint = allPoints[b]
     
     for i = a, b do 
          local distance = CalculateDistance(allPoints[i], startPoint, endPoint)
          if maxDistance == nil or distance > maxDistance then 
               farthestPoint = i
               maxDistance = distance
          end
     end
     
     -- Returns the index of the farthest point 
     -- If the index is -1 then there are no points left in the bounds of a and b to check for!
     return farthestPoint
end

-- Our recursive function for simplifying the curve
-- a and b are indices of the end points of the line segment we are checking for
local function DouglasPeucker(allPoints, simplified, a: number, b: number)
     local farthest = GetFarthestPoint(allPoints, a, b)
     
     -- If there exists a farthest point
     if farthest > 0 then 
          -- Continue the process with two line segments
          DouglasPeucker(allPoints, simplified, a, farthest)
          table.insert(simplified, allPoints[farthest])
          DouglasPeucker(allPoints, simplified, farthest, b)
     end
end

-- Simplify the curve
-- Keep the first and last point, then start the recursive algorithm.
table.insert(simplifiedCurve, points[1])
DouglasPeucker(points, simplifiedCurve, 1, #points)
table.insert(simplifiedCurve, points[#points])
```

That is it! Douglas-Peucker is the more well known curve and polyline simplification algorithm. It is widely used, but there are some edge cases that you'll run into for different kinds of curves and polylines but they shouldn't be hard to solve. Next we'll look into loops and polygons and how you can simplify them with this algorithm.

[Media Sources](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm)

# Douglas-Peucker Algorithm on Loops and Polygons



# Visvalingam-Whyatt Algorithm

# Conclusion

That is it for this article! It is a bit lengthy but it's worth knowing about these algorithms which will help the next time you have to generate curves. These algorithms are quite similar, all of them have the same goal, that is to simiply a curve but the procedures differ. So it is up to you on which algorithm you would want to make use of in your code. There are a few more algorithms that I haven't mentioned in this article due to them being very similar to the ones already explained.

Thank you for reading.
