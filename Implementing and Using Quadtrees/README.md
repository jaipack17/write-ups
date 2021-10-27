<div align="center"> 
    <h1>Quadtrees</h1>
    <p>Implementing and Using Quadtrees</p>
</div>
<hr/>

# Preface

Quadtrees are tree based data structures used prevalently in game development and computer graphics. These trees are used for organizing spatial information in a 2D space. These trees have at most 4 subdivisions/nodes. You might have heard about octrees before. Octrees are similar to quadtrees but unlike quadtrees, octrees are 3 dimensional and have 8 subdivisions that are cubes. These nodes, if visualized usually are squares, and their subdivisions are squares smaller than their parent node. Quadtrees are used in collision detection, game engines, image processing, mesh generation etc. In this article, we cover implementation, visualization of quadtrees as well collision detection with quadtrees. I also assume you know the basic architecture of how tree data structures work. If you aren't yet familiar with trees, consider checking them out before this article!

# Conceptual Understanding 

Quadtrees are usually mapped out in a 2 dimensional space with their subdivisions as quadrilateral regions. These regions subdivide into more regions, then those regions subdivide into more regions and this recursively goes on till a certain extent. We'll take a look both at graphs of quadtrees and regional representations.

They usually store data of points in a two-dimensional space. Each Node of a quadtree may or may not have subdivisions. To determine if a node has to subdivide into more nodes, we check the amount of points in a node/region. Each node has a 'capacity' that may or may not be constant for all nodes of a quadtree. This capacity determines the amount of points the node can have at once. If that amount exceeds the capacity, the node has to subdivide into 4 more nodes and this process continues. For instance, if a quadtree's nodes have a capacity of 1 point, and if 5 points are randomly spread across the 2 dimensional space, the quadtree may look like the following. The graph representation of the quadtree is also observable to the right. 

<img src="https://user-images.githubusercontent.com/74130881/138087580-5f0b342e-24ac-46cf-a236-8ba87ca64c98.png" alt="quadtree" width="300px" />&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/74130881/138088278-386d1baf-07fa-44c5-bfab-9f890c6f6c15.png" />

The positions of the points and the threshold for each node can varry thus giving us different sorts of results. But why bother about Quadtrees? Quadtrees make traversing through points 10 times more easier and efficient. Let's see how it makes our job easier and efficient.

Imagine a case of collision detection. There are entities spread across the screen. In order to detect if an entity collides with another, we usually loop through each entity, then loop through all entities and check if they collide. This is inefficient, why? Say you have 10 bodies. Each body checks collisions with all 10 bodies when traversing, this means, we end up performing 10^2, 100 checks in total. Let's step the number up from 10 to 10,000. How many checks do we perform this time? We perform 10000^2 or 100,000,000 checks. See how expensive this gets as you increase the amount of entities?

The reason why the method above is so inefficient is because of unnecessary and wasted collision detection checks. What is an unnecessary check? Suppose 2 entities are 1,000 units away from each other. Is it practically possible for them to collide when the checks are ran? Absolutely not. But, in the above method, we are still checking collisions with an entity 1,000 units away! Thats a wasted/unnecessary check!

![image](https://user-images.githubusercontent.com/74130881/138098124-b2696eb2-3ec8-4b42-bc7f-91c5cb01d883.png)

Quadtrees help out with this. They are efficient, fast and perfect for collision detection. Well, what makes them helpful? We'll look at this further ahead after we create a Quadtree.

# Implementing a Quadtree

We'll now write our own Quadtree class in lua. We start by setting up a constructor function for a Node. Note that the Node acts as a region in a quadtree. The Node has a capacity, position, width and height (size), a boolean determining if the node has been subdivided and an array of points inside that region. We'll refer these points as objects.

```lua
local Node = {}
Node.__index = Quadtree

function Node.new(_position: Vector2, _size: Vector2, _capacity: number)
	return setmetatable({
        	position = _position,
        	size = _size,
		capacity = _capacity,
		objects = {},
		divided = false,
	}, Node)
end

return Node
```

The next step would be to create an Insert() method which takes in a Vector2 (point) as a parameter, checks if a node has enough capacity to fit the point in, if not, it subdivides into 4 more nodes, this check continues until there's enough capacity for an intake.

```lua
function Node:Insert(point: Vector2)
	if not self:HasObject(point) then return end

	if #self.objects < self.capacity then 
		self.objects[#self.objects + 1] = p
		self:SubDivide()
	else
		if not self.divided then 
			self.divided = true
		end
	end

	self.topLeft:Insert(point)
	self.topRight:Insert(point)
	self.bottomLeft:Insert(point)
	self.bottomRight:Insert(point)
end
```

Well, we see some new stuff in their don't we? Let's break the method into different steps. Firstly, we have an unknown `HasObject` method. This method checks if a point is within the area of the node/origin. If not, we return from the function. Next we check if their's enough space for a point to fit in a region, if not the region subdivides into 4 more regions. This process continues until there's enough space for a point.

This method *may* cause memory leaks if the capacity is 1-2 and if the points are near the corners. A hacky way to deal with this would be to let some points be in a region even if their's not enough space. It's much better to use the method below for more performant quadtrees and also easier collision detection methods!

```lua
function Node:Insert(point: Vector2)
	if not self:HasObject(point) then return end

	if #self.objects < self.capacity then 
		self.objects[#self.objects + 1] = p
	else
		if not self.divided then 
			self:SubDivide()
			self.divided = true
		end
		
		self.topLeft:Insert(point)
		self.topRight:Insert(point)
		self.bottomLeft:Insert(point)
		self.bottomRight:Insert(point)
	end
end
```

Well, we have some unknown methods above, lets write them down as well. First would be the `HasObject()` method. We just compare the point's position with the bounds of the region and return a boolean.

```lua
function Node:HasObject(p: Vector2)
    return (
	(p.X > self.position.X) and (p.X < (self.position.X + self.size.X)) and 
	(p.Y > self.position.Y) and (p.Y < (self.position.Y + self.size.Y))
    )
end
```

Lastly, the `SubDivide()` method. We can first create a private method that would assist us to position and set the size of the region.

```lua
local function GetDivisions(position: Vector2, size: Vector2)
	return {
		position, -- [TOPLEFT]
		position + Vector2.new(size.x/2, 0), -- [TOPRIGHT]
		position + Vector2.new(0, size.y/2), -- [BOTTOMLEFT]
		position + Vector2.new(size.x/2, size.y/2), -- [BOTTOMRIGHT]
	}
end

function Node:SubDivide()
	local divisions = GetDivisions(self.position, self.size)
 
        -- create subdivisions

	self.topLeft = Node.new(divisions[1], self.size/2, self.depth)
	self.topRight = Node.new(divisions[2], self.size/2, self.depth)
	self.bottomLeft = Node.new(divisions[3], self.size/2, self.depth)
	self.bottomRight = Node.new(divisions[4], self.size/2, self.depth)
end
```

This explains the basics of how Quadtrees can be created. We'll look into another method used to traverse through a quadtree ahead when we'll use quadtrees for making collision detection faster than before. Other methods for updating and removing nodes shouldn't be hard to make, so take it as an exercise! If you have points that constantly change positions, it's better to replace the Vector2 with a custom Point class and store those points in different nodes. You can even render these Quadtrees on screen using the Size and Position properties of nodes! Here's a Quadtree I rendered in studio:

<img src="https://user-images.githubusercontent.com/74130881/138141637-7945e377-16e6-47a1-bf27-54ff5147553d.png" alt="quadtree-2" width="500px" />
 
# Quadtrees In Collision Detection

Initially we saw how efficient compared to traditional primitive methods of collision detection. So how do Quadtrees make collision detection efficient? Well you see, instead of checking for each point if the point collides with all the points excluding itself one after another, what if we could just filter points close to one? Here's where quadtrees help us out! 

Let's say you have 5 points on screen. Using the primitive method, you perform 5x5 = 25 collision detection checks in total. Now lets say you have quadtrees! There are different regions with different amounts of points. What if we just iterate through the points, fetch the closets points to it and perform checks with just these few points! See how that reduces so many unnecessary checks? 

In order to fetch all other points **close** to a particular point, we need the position of the point we are checking for as well as some bounds. These bounds define the extent of searching for points closer to the particular point. This boundary may be a rectangle, a square, a circle or any other shape! For simplicity sake, we'll use squares. It shouldn't be hard to implement circles or rectangles for the boundaries though. 

Here's the visualization of how this boundary is going to help us. The red point is the point we are fetching the closest points for. The range and the closest points are depicted in green, the rest in white. 

<img src="https://user-images.githubusercontent.com/74130881/138230790-760ba789-eaa9-477e-8ff2-4d6e05358917.png" alt="example-1" width="400px" />

Quadtrees are going to help a lot to filter the points that are no where close to the point to check for. Let's write a `Search()` method in the Node class that takes in a point and some boundary, then spits out other points close to it.

```lua
function Node:Search(range: { position: Vector2, size: Vector2 }, closestObjects) -- closestObjects empty initially
    if not closestObjects then 
    	local objects = {} -- array of closest points
    end

    if not RangeOverlapsNode(range) then 
       return objects
    end

    for _, obj in ipairs(self.objects) do
    	if RangeHasPoint(obj) then
            objects[#objects + 1] = obj
        end
    end
 
    if self.divided then
        merge(objects, self.topLeft:Search(range, objects))
        merge(objects, self.topRight:Search(range, objects))
        merge(objects, self.bottomLeft:Search(range, objects))
        merge(objects, self.bottomRight:Search(range, objects))
    end

    return objects
end
```

Let's see what we have here. Firstly we define an array which will consist of all the points in the range. Next we check if the range overlaps the Node, if not just return an empty array. If these two checks pass, we iterate through our points, check if the point lies within the range and push the point into the array. Further ahead we check if the Node has subdivisions, if yes we recursive go through each subdivision, fetch the points in the subdivision **that are within the range** and concatenate the objects array with the fetched subdivision points.

There are a few unknown methods in there, including `RangeOverlapsNode()`, `RangeHasPoint()` and `merge()`. I won't be covering these methods. Those algorithms are not at all tricky to implement. Take this one as an exercise as well! 

You can then use the `Search()` method in your code.

```lua
local range = ... -- some range

for _, p in ipairs(pointsArray) do
    local closestPoints = QuadtreeRoot:Search(range)

    for _, other in ipairs(closestPoints) do
        -- detect and process collisions
    end
end
```

Note that you shouldn't render quadtrees on the screen since that's just unnecessary and a waste of resources. It is fine for debugging but not production code.

Quadtrees makes iterating through a large amount of data easier than before! Something that took us 100,000,000 checks, now takes us a lot lesser. Here's a comparison of 1,000 particles. 1 uses the primitive method of iterating through the particles while the latter uses quadtrees! The particles in white are particles that are in some form of collision. Notice the difference in the frame rate?

[Media Source](https://editor.p5js.org/codingtrain/sketches/CDMjU0GIK)

<img src="https://user-images.githubusercontent.com/74130881/138237758-d1cd9b6c-0483-433c-8bb0-719a83140d67.gif" alt="example-1" width="450px" />&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/74130881/138238253-91411368-f443-4525-8c9a-3feac233ce05.gif" alt="example-1" width="450px" />

To update quadtrees based on the positions of an object, you should use custom classes for points instead of just vectors. To update the quadtree, you can use computation, maybe create a new quadtree every frame? Maybe clear the quadtree and add all the points once again. It's for you to find out! 

The method above can be made much more performant than how it is currently. There are still a lot of wasted checks. Here's how checks are wasted. Take the example of just two points.

![image](https://user-images.githubusercontent.com/74130881/138239352-44efed13-9ef2-4627-85f7-969cffd0ee14.png)

Here, when we check for collisions between point 1 and point 2, we see that they aren't colliding. Iterating through these two points, we are unnecessarily having an extra check. If we already denote that point 1 does not collide with point 2, what's the need of checking if point 2 collides with point 1 (difference in sequence/order)? Exactly, there's no necessity. Some sort of cache to store points that have already been checked for collisions can be made and used accordingly.

<hr/>

I hope you learnt something new today. Quadtrees can be used for a wide variety of things, more than just collision detection. You should definitely experiment with quadtrees in the future. Here are some excellent resources you can learn more about quadtrees from:

* [An Explaination of Quadtrees - MrHeyheyhey27](https://www.youtube.com/watch?v=jxbDYxm-pXg)
* [Coding the Visualization of Quadtrees - The Coding Train](https://www.youtube.com/watch?v=OJxEcs0w_kE)
* [Quadtrees and Octrees - Tyler Scott](https://www.youtube.com/watch?v=xFcQaig5Z2A)

Thank you for tuning in!
