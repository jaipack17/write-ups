<div align="center">
     <h1>Optimizing Curves Algorithmically</h1>
     <p>A few techniques and algorithms for curve and polyline simplification</p>
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

When rendering curves on the screen, we use up a lot objects to cover up the spaces between and to connect points (lying on the curve) together. Sometimes if not always, we tend to use more objects than actually necessary, this can hurt performance and take up a lot of memory. In this write-up, I cover a few methods that can help reduce memory usage when dealing with curves. 

The techniques I'll be sharing are very beneficial for a number of situations. These include - drawing bezier curves, splines, optimizing drawing tools, curved paths for roads, generative art, procedural animations, visualizing topological data etc. If you're dealing with such cases, stick around till the end.

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

You can apply this optimization after calculating the points and during the rendering process or directly when calculating the points of the curve. It is also worth noting that it may not always be the case that the points lie **exactly** on the same straight line thus giving not so interesting optimization results. To counter this problem, you could check the perpendicular distance between the point and the straight line you are checking for. If the distance is less than some threshold, you could say that 'the point lies on the line'. Also take a note that the larger this threshold, the lesser the resolution of the curve. There is an edge case to the distance check. If a point is close to the line but isn't in the direction where `next - start` vector is pointing, then it's going to malform the curve. To fix this, you may want to also check the direction in which the point lies.

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
-- Fidget around with the epsilon to get the correct results!
local epsilon = 10

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
     
     if maxDistance < epsilon then 
	  farthestPoint = -1
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

-- Draw the simplified curve
local previous = nil
for _, p in ipairs(simplifiedCurve) do 
     if previous then 
     	  DrawLineSegment(p, previous)
     else 
	  previous = p  
     end
end
```

That is it! Douglas-Peucker is the more well known curve and polyline simplification algorithm. It is widely used, but there are some edge cases that you'll run into for different kinds of curves and polylines but they shouldn't be hard to solve. Next we'll look into loops and polygons and how you can simplify them with this algorithm.

[Media Sources](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm)

# Douglas-Peucker Algorithm on Loops and Polygons

Lets talk about how we'd simplify loops and closed polygons with the Douglas-Peucker algorithm. The algorithm seems to work fine on polylines and curves, but to make it work for closed figures is a bit trickier. Let's say we have a closed figure, we consider the code we wrote above without any new modifications. Running the simplification algorithm on this closed figure may give you inaccurate or even incorrect results.

The reason to this is because of how we select our starting points initially. Let's walk through a few examples. For the first example we arbitrarily choose two random points of the closed figure to be the starting points for our algorithm. Lets consider our closed figure to have atleast 60 points as its vertices, choosing something random like the 10th and the n-40th index will do. Run the algorithm on this closed figure and observe. Here's the result for my closed figure before and after running the algorithm. The starting points are highlighted with green.

<img src="https://user-images.githubusercontent.com/74130881/150668202-defcb3c4-eed1-42c4-a384-1d7c74120bb0.png" width="450px" /> <img src="https://user-images.githubusercontent.com/74130881/150668233-936ec60c-fa29-431d-9d30-27242a60d444.png" width="400px" />

The algorithm was able to bring the number of line segments we use to draw the closed figure from 120 to 41, but gives an incorrect figure. Why is that so? It is because of the incorrect order of points given by the algorithm to us after the simplification of the closed figure! Well why did this happen? Since the starting points are randomly assigned, the points that are outside the bounds of the indices of these selected points are not included as a part of the closed figure by the algorithm!

The start and end point of a closed figure are the same, so... how can we choose our starting points? We have a few cases that can help us. We can set the last index of the array of points to be the same as the first, consider both the points at the first and the last index as the starting points and run the algorithm. We'll notice that the algorithm works perfectly! Another method would be to consider the first point of the array and the last point of the array without ever editing or omitting the array and use these as the starting points. The point farthest to the line segment formed by these starting points will be chosen and the algorithm would work just fine.

If the above methods don't seem to work as well, we have another choice! To go back to choosing random starting points or choosing the first starting point and the point farthest to it as the end point. The algorithm won't work just yet. But, we'll now divide the array of points into different arrays according to the indices of these points and run the algorithm of both arrays for simplification! 

# Visvalingam-Whyatt Algorithm

The Visvalingam-Whyatt algorithm isn't as popular as the Douglas Peucker algorithm but serves a great hand in the simplification of curves and polylines and may even be more effective than Douglas-Peucker due to the small number of edge cases it has. It's used to discard/remove any points that are not needed for the simplified curve unlike the Douglas Peucker algorithm where we look for points to keep. This algorithm has a really interesting and easy approach.

It has a very simple procedure, we consider an epsilon or a threshold that's a number, just like the Douglas-Peucker algorithm. Next we iterate through the points of the curve. For every 3 consecutive points, we form a triangle. If the area of the smallest triangle is less than the epsilon, the triangle is removed by deleting the point that lies between the bounds of the other two points, this process continues until we have no triangle left with the area smaller than the epsilon. This algorithm is great for simplifying polygons, curves and polylines!

<img src="https://user-images.githubusercontent.com/74130881/150669687-8a2f21c1-56b5-4a5e-a710-d331cb33b503.png" width="500px" />

For the implementation, we simply iterate through the points, form triangles, remove the smaller triangle with the area lesser than the epsilon, over and over again until we have no triangles that have areas lesser than the epsilon. We'll be storing these triangles in an array but using a min-heap data structure will give better and faster results for finding the triangle with the smallest area out of all.

```lua
local points = { ... }
local epsilon = 5

-- Use heron's formula to calculate area of the triangle.
local function CalculateAreaOfTriangle(a, b, c)
     local ab = (b - a).Magnitude
     local bc = (b - c).Magnitude
     local ac = (c - a).Magnitude

     local s = (ab + bc + ac)/2

     return math.sqrt(s * (s - ab) * (s - bc) * (s - ac))
end

local function VisvalingamWhyatt(points) 
     local minArea = nil
     local pointToRemove = -1
     
     -- Start traversing the points from the 3rd index to the last
     for i = 3, #points, 1 do 
	  local a = points[i - 2]
	  local b = points[i - 1]
	  local c = points[i]

	  -- Caculate minimum area
	  local area = CalculateAreaOfTriangle(a, b, c)
	  if minArea == nil or area < minArea then
		minArea = area
		pointToRemove = i - 1
          end
     end

     -- Check if minimum area is greater than the epsilon, if yes then stop the algorithm.
     if minArea >= epsilon then 
	  pointToRemove = -1
     end
      
     if pointToRemove > 0 then 
	  table.remove(points, pointToRemove)
	  -- If any triangles can be formed, continue the algorithm
	  if #points > 2 then 
	       VisvalingamWhyatt(points)
       	  end
     end
end

VisvalingamWhyatt(points)

local prev = nil
for _, p in ipairs(points) do 
	if prev then 
		DrawLine(p, prev, canvas.Drawn, 3, Color3.new(1, 1, 1))
		prev = p
	else 
		prev = p
	end
end
```

You can once again fidget around with the epsilon for the result you desire. I find this algorithm to be better than Douglas-Peucker because of its simplicity and effectiveness. The choice is yours! Here's the algorithm in action

<img src="https://user-images.githubusercontent.com/74130881/150672264-73e6c3d3-508f-4d00-a6b0-2f8793ae4a16.gif" width="450px" />

# Conclusion

That is it for this article! It is a bit lengthy but it's worth knowing about these algorithms which will help the next time you have to generate curves. These algorithms are quite similar, all of them have the same goal, that is to simiply a curve but the procedures differ. So it is up to you on which algorithm you would want to make use of in your code. There are a few more algorithms that I haven't mentioned in this article due to them being very similar to the ones already explained. If you wish to read about more algorithms for line simplification, you'll find some great writings about Reumann–Witkam, Opheim and a few other algorithms online!

Thank you for reading.
