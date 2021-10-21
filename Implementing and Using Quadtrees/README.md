<div align="center"> 
    <h1>Quadtrees</h1>
    <p>Implementing and Using Quadtrees</p>
</div>
<hr/>

# Preface

Quadtrees are tree based data structures used prevalently in game development and computer graphics. These trees have at most 4 subdivisions/nodes. You might have heard about octrees before. Octrees are similar to quadtrees but unlike quadtrees, octrees are 3 dimensional and have 8 subdivisions that are cubes. These nodes, if visualized usually are squares, and their subdivisions are squares smaller than their parent node. Quadtrees are used in collision detection, game engines, image processing, mesh generation etc. In this article, we cover implementation, visualization of quadtrees as well collision detection with quadtrees. I also assume you know the basic architecture of how tree data structures work. If you aren't yet familiar with trees, consider checking them out before this article!

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

The next step would be to create an Insert() method which takes in a Vector2 (point) as a parameter, checks if a node has enough capacity to fit the point in, if not, it subdivides into 4 more nodes, this check continues until there's enough capacity to fit in a point.

```lua
function Node:Insert(point: Vector2)
	if not self:HasObject(p) then return end

	if #self.objects < self.capacity then 
		self.objects[#self.objects + 1] = p
		self:SubDivide()
	else
		if not self.divided then 
			self.divided = true
		end
	end

	self.topLeft:Insert(p)
	self.topRight:Insert(p)
	self.bottomLeft:Insert(p)
	self.bottomRight:Insert(p)
end
```

Well, we see some new stuff in their don't we? Let's break the method into different steps. Firstly, we have an unknown `HasObject` method. This method checks if a point is within the area of the node/origin. If not, we return from the function. Next we check if their's enough space for a point to fit in a region, if not the region subdivides into 4 more regions. This process continues until there's enough space for a point.

This method *may* cause memory leaks if the capacity is 1-2 and if the points are near the corners. A hacky way to deal with this would be to let some points be in a region even if their's not enough space.

```lua
function Node:Insert(point: Vector2)
	if not self:HasObject(p) then return end

	if #self.objects < self.capacity then 
		self.objects[#self.objects + 1] = p
	else
		if not self.divided then 
			self:SubDivide()
			self.divided = true
		end
		
		self.topLeft:Insert(p)
		self.topRight:Insert(p)
		self.bottomLeft:Insert(p)
		self.bottomRight:Insert(p)
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
local function GetDivisions(pos: Vector2, size: Vector2)
	return {
		pos, -- [TOPLEFT]
		pos + Vector2.new(size.x/2, 0), -- [TOPRIGHT]
		pos + Vector2.new(0, size.y/2), -- [BOTTOMLEFT]
		pos + Vector2.new(size.x/2, size.y/2), -- [BOTTOMRIGHT]
	}
end

function Quadtree:SubDivide()
	local divisions = GetDivisions(self.position, self.size)

	self.topLeft = Quadtree.new(divisions[1], self.size/2, self.depth)
	self.topRight = Quadtree.new(divisions[2], self.size/2, self.depth)
	self.bottomLeft = Quadtree.new(divisions[3], self.size/2, self.depth)
	self.bottomRight = Quadtree.new(divisions[4], self.size/2, self.depth)
end
```

This explains the basics of how Quadtrees can be created. We'll look into another method used to traverse through a quadtree ahead when we'll use quadtrees for making collision detection faster than before. Other methods for updating and removing nodes shouldn't be hard to make, so take it as an exercise! If you have points that constantly change positions, it's better to replace the Vector2 with a custom Point class and store those points in different nodes. You can even render these Quadtrees on screen using the Size and Position properties of nodes! Here's a Quadtree I rendered in studio:

<img src="https://user-images.githubusercontent.com/74130881/138141637-7945e377-16e6-47a1-bf27-54ff5147553d.png" alt="quadtree-2" width="500px" />
 
# Quadtrees In Collision Detection

Initially we saw how efficient compared to traditional primitive methods of collision detection. So how do Quadtrees make collision detection efficient? Well you see, instead of checking for each point if the point collides with all the points excluding itself one after another, what if we could just filter points close to one? Here's where quadtrees help us out! 

Let's say you have 5 points on screen. Using the primitive method, you perform 5x5 = 25 collision detection checks in total. Now lets say you have quadtrees! There are different regions with different amounts of points (?). What if we just iterate through the points, fetch the closets points to it and perform checks with just these few points! See how that reduces so many unnecessary checks? 

* To be completed
