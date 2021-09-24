<div align="center">
<h1>The Beauty of Verlet Integration</h1>
<p>How I created a smooth Ragdoll, with nothing but Guis</p>
</div>
<hr/>

# Overview

One of fanciest if not the most optimal way of simulating physics in physics engines, computer graphics and games is the Verlet Integration. One of the famous 2D Physics engine that goes by the name of [Box2D](https://box2d.org/) uses this integration. Another physics engine that run in the browser, for example [matter.js](http://brm.io/matter-js/) also uses this magical way of smooth physics simulations. 

![physics](https://github.com/jaipack17/write-ups/blob/main/Verlet%20Integration/assets/e10d034c2caff9088243b0bc17cddb016e0e8a3f.gif?raw=true)

If you want to learn more about verlet integration, want to make smooth physics simulations using guis or are just curious, then this article is an engrossing adventure for you. 

Now to the jewel of this article. **What is verlet integration?** Verlet is a set of mathematical algorithms used to integrate physics in terms of Newton's laws of motion. It is mostly used in Computer Graphics and Game Development. It lies around points connected with line segment and realistic motion. We'll look into the algorithms in a moment, but first I'd like to share why I am making this topic. After all, Roblox isn't made for 2D games that consist of only UI elements, and that's the reason I have written this for you, to give you sort of an idea and an overlook of how you can simulate physics in roblox using merely guis! @EgoMoose has written [a beautiful article](https://drive.google.com/file/d/0B8NceKcllVYrXzhlaDFWdHp5YTg/view?resourcekey=0-oKq1itaKAZCvP7sZRWVopg) for Verlet Integration inclined towards 3D objects, so be sure to check that out if you are more into 3D Verlet Integration than 2D.

I will be covering the fundamentals as well as how I created this ragdoll using only guis and verlet integration:

![RgPPBoeTRG (online-video-cutter com)](https://user-images.githubusercontent.com/74130881/134695238-a2c85353-c377-4ba6-aebe-dead59b761b6.gif)

<hr/>

# Creating Attachments - Points

Verlet Integration can be used to create cloth simulations, ragdolls, ropes, swings, rigid bodies and other such physics simulations.

Before diving into how it works and how to code something like this, you must have knowledge about Vectors, Vector math operations, knowledge about basic geometrical and physical terms/quantities.

To begin with Verlet Integration, it is important to know how it works.

Verlet integration works on the basis of points that act as attachments and joints for different line segments. These line segments connect different points to keep uniform distance between two points even when in motion. The beauty of verlet is such that these points and segments can be used to create realistic cloth, rope, ragdolls and other physics simulations.

We can use verlet integration to create custom physics engines.

![cloth](https://github.com/jaipack17/write-ups/blob/main/Verlet%20Integration/assets/cloth.gif?raw=true)

<hr/>

Now onto the fundamantals. How do we create these points and line segments? How do we connect them?

The answer to all these questions are fairly easy to understand and to apply to your code. Note that we'll be using guis for the rest of this tutorial. Using simple object oriented programming, we can create a Point class.

```lua
local Point = {}
Point.__index = Point

function Point.new(posX, posY, visible)
    -- creating the UI element for debugging/visualization processes.

	local ellipse = Instance.new("Frame")
    ellipse.Size = UDim2.new(0, 5, 0, 5) -- circle of diameter 5
    ellipse.Position = UDim2.new(0, posX, 0, posY)
    ellipse.BackgoundColor3 = Color3.new(0, 1, 0) -- green
    ellipse.Visible = visible 
	ellipse.Parent = canvas -- canvas aka frame that will hold this ellipse
	
    -- metatable

	local self = setmetatable({
		frame = ellipse, -- our UI element
		oldPos = Vector2.new(posX, posY), -- previous position (Starts with initial position)
		pos = Vector2.new(posX, posY), -- current position
		forces = Vector2.new(0, 0), -- forces to be applied to the UI element.
		stiff = false, -- should it not move?
	}, Point)
	
	return self 
end

function Point:ApplyForce(force)
	self.forces += force
end

return Point
```

Previous position and current position are two important vector quantities that we will be using in this tutorial. Previous position would store the position right before movement forces are applied to the point, and the current position changes as we move the point.

We won't be moving line segments, but only points. Naturally, line segments joining these points will appear as if the segments are moving.

The ApplyForce function is used to apply forces to the UI element, mainly the gravitational force.

Now to simulate this point to be attracted by the ground to simulate a gravitational pull and to apply frictional forces, we can create another function.

```lua
function Point:Simulate()
	if not self.stiff then
		local gravity = Vector2.new(0, .1)
		self:ApplyForce(gravity) -- apply gravitional force
		
		local velocity = self.pos 
		velocity -= self.oldPos
		velocity += self.forces  
		
		local friction = .99
		velocity *= friction -- apply frictional force to the velocity
		self.oldPos = self.pos -- set old position before moving the ui element
		self.pos += velocity -- finally moving the ui element
		self.forces *= 0 -- setting forces back to 0 to prevent infinite movement
	else
		self.oldPos = self.pos
	end
end
```
We have a simulation function, but when running what we have till now, you'll notice the point just falls down infinitely.

To prevent this from happening, we'll create another function that checks if the point goes past the borders of the screen, if it does, it brings the point back inside and applies a bounce force to it to simulate smooth collisions

```lua
local height = workspace.CurrentCamera.ViewportSize.Y
local width = workspace.CurrentCamera.ViewportSize.X
local bounce = .8 -- bounce force damp value between 0 and 1

function Point:KeepInCanvas()
	local vx = self.pos.x - self.oldPos.x; -- velocity.x
	local vy = self.pos.y - self.oldPos.y; -- velocity.y
		
	if self.pos.y > height then -- if it crosses the bottom edge
		self.pos = Vector2.new(self.pos.x, height) -- adjust position 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y + vy * bounce) -- apply bounce force
	elseif self.pos.y < 0 then -- if it crosses the top edge
		self.pos = Vector2.new(self.pos.x, 0) 
		self.oldPos = Vector2.new(self.oldPos.x, self.pos.y - vy * bounce)
	end
	
	if self.pos.x < 0 then -- if it crosses the left edge
		self.pos = Vector2.new(0, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x + vx * bounce, self.oldPos.y)
	elseif self.pos.x > width then -- if it crosses the right edge
		self.pos = Vector2.new(width, self.pos.y) 
		self.oldPos = Vector2.new(self.pos.x - vx * bounce, self.oldPos.y)
	end
end
```
Cool we have everything setup. Now to render this point every frame, we'll run a function every RenderStepped, which does nothing but sets the UI element's position to `self.pos` and run the KeepInCanvas function!

```lua
function Point:Draw()
	self.frame.Position = UDim2.new(0, self.pos.x, 0, self.pos.y) -- this is optional and only for debugging purposes.
	self:KeepInCanvas()
end
```

Note, that rendering points isn't needed at all as it may give rise to performance issues, I like to use it for debugging processes only.

<hr/>

# Creating Segments
We just created points. So.. Why not connect these points with segments to form polygons? To do this, we'll create another class! The constructor takes in a few arguments. The first 2 being point 1 and point 2. The segment will be connected to these 2 points

```lua
local Segment = {}
Segment.__index = Segment

function Segment.new(p1, p2, visible, th)
	local self = setmetatable({
		frame = line(0, 0, 0, 0, canvas, th), -- line segment's UI element
		point1 = p1,
		point2 = p2, 
		length = (p2.pos - p1.pos).magnitude, -- minimum length possible
		visible = visible, 
		th = th or 4 -- thickness
	}, Segment)
	
	return self	
end

return Segment
```

You might have noticed the `line()` function that I wrote there. That function will be used to render the line segment on the screen.

The math behind it, is fairly simple. Just find the angle between the two points, then, rotate and position the frame correctly!

```lua
local function draw(hyp, origin, thickness, parent, l) 
	local line = l or Instance.new("Frame")
	line.Name = "line"
	line.AnchorPoint = Vector2.new(.5, .5)
	line.Size = UDim2.new(0, hyp, 0, thickness or 1)
	line.BackgroundColor3 = Color3.new(1,1,1)
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(origin.x, origin.y)
	line.ZIndex = 1
	line.Parent = parent
	
	return line
end

function line(originx, originy, endpointx, endpointy, parent, thickness, lineToUpdate)
	local origin = {
		x = originx,
		y = originy
	}
	
	local endpoint = {
		x = endpointx,
		y = endpointy
	}
	
	local adj = (Vector2.new(endpoint.x, origin.y) - Vector2.new(origin.x, origin.y)).magnitude
	local opp = (Vector2.new(endpoint.x, origin.y) - Vector2.new(endpoint.x, endpoint.y)).magnitude
	local hyp = math.sqrt(adj^2 + opp^2)
	
	local line = lineToUpdate and draw(hyp, origin, thickness, parent, lineToUpdate) or draw(hyp, origin, thickness, parent)		
	local mid = Vector2.new((origin.x + endpoint.x)/2, (origin.y + endpoint.y)/2)
	
	local theta = math.atan2(origin.y - endpoint.y, origin.x - endpoint.x)
	theta /= math.pi
	theta *= 180
		
	line.Position = UDim2.fromOffset(mid.x, mid.y)
	line.Rotation = theta
	
	return line
end
```

We'll mostly use this in our code. origin and endpoint parameters will be the two points which the line segment will be connected to. The lineToUpdate parameter is the frame, and we are just updating the position and rotation of the frame. This method is basically reusing frames that we initialized and updating them accordingly. 

To Render this UI element every frame, we do the same thing we did for Points, but use the line() function!

```lua
function Segment:Draw()
	if self.visible then -- if visible, create a line!
		line(self.point1.pos.x, self.point1.pos.y, self.point2.pos.x, self.point2.pos.y, script.Parent.Parent.Canvas, self.th, self.frame)
	end
end
```
This function reuses `self.frame` and updates the UI element! 

But, as our points move, we should keep a constant distance between the points! So we'll create another function that does this job.

```lua
function Segment:Simulate()
	local currentLength = (self.point2.pos - self.point1.pos).magnitude -- length of the segment
	local lengthDifference = self.length - currentLength -- difference of minimum length and currentlength
	local offsetPercent = (lengthDifference / currentLength) / 2 -- offset
	
	local direction = self.point2.pos 
	direction -= self.point1.pos 
	direction *= offsetPercent -- direction to pull the point back to maintain constant length
	
	if not self.point1.stiff then
		self.point1.pos -= direction -- updating point's position
	end
	
	if not self.point2.stiff then
		self.point2.pos += direction -- updating point's position
	end
end
```
We have our attachments and segments ready to render now! So lets try making a Box that moves according to your mouse location and bounces off the edges!

# Making a bouncy box

We'll now use our Points and Segments to create a Box that clings to your cursor when you hold it and bounces off the edges! In this part of the tutorial, we'll create something the following:

https://user-images.githubusercontent.com/74130881/134695653-dcf0972c-ebc5-4c8c-b5c4-46567aea178a.mp4

This is nothing but 4 points connected with line segments :wink: 

Sooo, lets start with initialization of how our box would look! Here, we'll store the segments and points in a table. We'll keep the points visible for visualization.

```lua
local Segment = require(path.to.module)
local Point = require(path.to.module)

local points = {}
local segments = {}

function Setup()
   -- four corners of the box
 
   local topLeft = Point.new(300, 300, true)
   local topRight = Point.new(350, 300, true)
   local bottomLeft = Point.new(300, 350, true)
   local bottomRight = Point.new(350, 350, true)
   
   points = { topLeft, topRight, bottomLeft, bottomRight }
  
   -- segments of the box

   local leftEdge = Segment.new(topLeft, bottomLeft, true)
   local topEdge = Segment.new(topLeft, topRight, true)
   local rightEdge = Segment.new(topRight, bottomRight, true)
   local bottomEdge = Segment.new(bottomLeft, bottomRight, true)
end

Setup()
```

When, we'll make these points movable, you'll notice the box will just collapse. To prevent this from happening, we'll join the Top left corner with the bottom right. This line segment is a "Support Beam" and gives the box durability to not collapse. You can make it invisible, but for debugging processes we'll render it.

```lua
local support = Segment.new(topLeft, bottomRight, true)
```

Lets run this, And...

![image](https://user-images.githubusercontent.com/74130881/134695706-9ebadc4c-3da9-4201-b2ce-e53a77c28c09.png)

Hmm? There's nothing on the screen? You'll notice that we never really rendered the elements using :Draw(), so the points and segments remain at their initial position which in our case was 0, 0!

So lets render these points and lines every frame!

```lua
function Render()
   for timeStep = 1, 6 do
       for _, point in ipairs(points) do
            point:Simulate() -- simulation
       end
   end

   for _, segment in ipairs(segments) do
  		segment:Simulate() -- simulate segments
   end

   for _, point in ipairs(points) do
		point:Draw() -- rendering on screen
   end
	
   for _, segment in ipairs(segments) do
     	segment:Draw() -- rendering on screen
   end
end
```
We use a TimeStep loop here, timesteps are used to render something multiple times in a given time frame. Here we simulate the position of the segment 6 times in a time frame!

Now, lets run this!

https://user-images.githubusercontent.com/74130881/134695733-7cfce62c-83ea-405c-9d60-8a021d654b99.mp4

Amazing! The points are visible in green, you can also see the support beam. The points uniformly fall down due to our segments pulling them to keep constant distance between the points!

Selecting points and moving them around on the screen is fairly simple using UserInputService, so I won't be covering that. When you implement selection of points, you'll notice a smooth and realistic movement of the box on the screen, with the act of gravitational forces on the points and the beauty of Verlet integration you get this result:

https://user-images.githubusercontent.com/74130881/134695759-cb4001e1-cf47-4356-b840-19fae8c0210e.mp4

If it feels to bobbly, you can add another support beam which connects the topright corner and bottom left corner of the box:

https://user-images.githubusercontent.com/74130881/134695786-230d7ca4-c2a8-4b21-bb91-557855982489.mp4

Looks great to me! You can play around with points and segments to create other kinds of quadrilaterals and even polygons with more or less than 4 sides!

<hr/>

# How I made the Ragdoll
I made this article to explain to you all, how I made the ragdoll I showcased towards the beginning of the tutorial along with the fundamentals of Verlet Integration. So far, you must have got the gist of how magical Verlet Integration can be.

Making a ragdoll was fairly simple. I used the same Points and Segments I used to make the box above! But with just a few more points and segments to make it look like a Human Ragdoll!

Firstly, something I forgot to explain above, How do OBB Collisions in Verlet Integration work? "I didn't see you code them?", this is what many of you would say. But the thing is, Verlet Integration itself handles them for me! And technically fakes OBB Collisions!

Here's how:

![image|598x500](https://doy2mn9upadnk.cloudfront.net/uploads/default/optimized/4X/d/4/8/d480643999323749376b2f2b0a53f74c2cfb6293_2_897x750.png)

When a point collides with the edges of the screen, a bounce force is applied to it. Which naturally causes a change in its position and the line segment's position! Hence, faking OBB Collisions when rendering!

Now, to the next point. How exactly did I connect the points to make it look like a human? Here's a rig of all the joints (points) and bones (segments)!

![image|379x499](https://doy2mn9upadnk.cloudfront.net/uploads/default/optimized/4X/f/0/f/f0f22196276ea27eed19a31abe489da67aef420c_2_568x748.png)

*Yeah, I know they are the most perfectly straight lines ever seen.*

That's just the basic Idea of how the Rig of the Ragdoll looks behind the scenes with the Support Beams. Its a combination of quadrilaterals and free rope like limbs!

Then, using UserInputService I make the points selectable and draggable! Verlet Integration is super cool and flexible that it does the job of realistic movement of the ragdoll (which isn't an active ragdoll) so smoothly with the basic algorithm that I discussed above in the article!!

Here's the ragdoll in action:

https://user-images.githubusercontent.com/74130881/134695893-4fef48cf-0425-4a07-b580-8e6f4041c7d1.mp4

If you would like to take a glimpse at the code behind this ragdoll, feel free to view it and edit it! It can be found in the placefile below:

[Verlet Integration - Ragdoll.rbxl|attachment](upload://3pDHLrA3zazHXw4fhDFESdqG471.rbxl) (35.1 KB)

<hr/>

# Conclusion

Not only are these ragdolls fun to control and play around but also fun to make! I would love to see your own versions/edits of the ragdolls! If you do make one or make something different with Verlet Integration! If you would like to read more about Verlet Integration and the deep mathematical equations, don't forget to check out this wikipedia page!

https://en.wikipedia.org/wiki/Verlet_integration

If you want to just have fun playing with the ragdoll, you can do so here:

https://www.roblox.com/games/7470238300/Verlet-Integration-Ragdoll

That's it from me today,
Thanks!
