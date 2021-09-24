<div align="center">
   <h1>Steering Behaviors</h1>
   <p>Steering Behaviors For Autonomous Characters</p>
</div>

<hr/>

## Table of Contents
* [Preface -  What are Steering Behaviors?](#Preface -  What are Steering Behaviors?)
* [Coding Steering Behaviors](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#coding-steering-behaviors-3)
    * [Seek Steering Behavior](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#seek-steering-behavior-4)
    * [Flee Steering Behavior](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#flee-steering-behavior-5)
    * [Arrival Steering Behavior](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#arrival-steering-behavior-6)
    * [Pursue Steering Behavior](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#pursue-steering-behavior-7)
    * [Evade Steering Behavior](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#evade-steering-behavior-8) 
    * [Wander Steering Behavior](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/6)
    * [Cleaning up messy code](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#cleaning-up-messy-code-9)
    * [Grouping Steering Behaviors](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#grouping-steering-behaviors-10)
* [Conclusion](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/1#conclusion-11)

<hr/>

# Preface -  What are Steering Behaviors?

When it comes to moving characters, objects, vehicles and other autonomous objects in a natural and realistic fashion, we use Steering Behaviors. In the early 1990s, computer scientist [Craig Reynolds](http://www.red3d.com/cwr) developed algorithmic steering behaviors for autonomous agents. These behaviors allowed individual elements to navigate their digital environments with strategies for seeking, fleeing, wandering, arriving, pursuing, evading, avoiding an obstacle, following a path. 

Steering behaviors help us control objects in the world like actual human beings. The ability to give objects human like physics and eyesight is a huge deal and a fascinating concept for many. These steering behaviors are tricky to crack but with the help of RayCasting and a few algorithms by Craig Reynolds, we can together figure them out! Today we'll be taking a peak inside these Steering Behaviors and making something cool!

![xd](upload://mn1qlBU0LBzPTggltWW91rS6quD.gif)

> Source
https://www.red3d.com/cwr/steer/

<hr/>

# Coding Steering Behaviors

Lets code some of the most famous Steering Behaviors! We'll be scripting these Steering Behaviors from scratch, but also combining behaviors to create something really cool!

* Seek Steering Behavior
* Flee Steering Behavior
* Arrival Steering Behavior
* Pursue Steering Behavior
* Evade Steering Behavior

And then:

* Grouping Steering Behaviors

### Seek Steering Behavior

> https://www.red3d.com/cwr/steer/SeekFlee.html

Now, many of you, after seeing what seek does, will say, *"Psst. why not just use TweenService? Its easier."*. And the answer is. Never. You should never use TweenService for demonstrating character movement and physics in a 2D Game. TweenService is highly inflexibly in this scenario.

Lets look at what Seek really means.

Seek attempts to steer a vehicle so that it moves toward the goal. This is in contrast to a central force (such as gravity) which causes an inward acceleration and so leads to orbital motion. Seek applys a steering force in the direction which is the difference between the current velocity and the desired velocity. 

In simple words, make the object steer towards a goal

![](upload://zzRRSmK94Zx9brMTtOsP6wUtfoa.gif)

We'll create a "Mover" module which will contain all the functions for each steering behavior we code.

```lua
local offset = Vector2.new(0, 36) -- this is to fix my studio absoluteposition bug, if you get weird results, set it to 0, 0

local Mover = {}
Mover.__index = Mover

function Mover.new(frame)
	local self = setmetatable({
		frame = frame,
		velocity = Vector2.new(0, 0),
		acceleration = Vector2.new(0, 0),
		position = frame.AbsolutePosition
	}, Mover)
	
	return self
end

return Mover
```

This mover has a frame, a velocity, constant acceleration and a position. To code the Seek Steering Behavior. We use a simple formula

*`steeringForce = desiredVelocity - velocity`*

![image|690x163](upload://iZc66RcAc3mCbDP5MXmdsXUNEAO.png)

We apply the steeringForce to the object, which changes its velocity over time. Lets code this out!

```lua
local offset = Vector2.new(0, 36) -- this fixes my studio absoluteposition bug, if you get weird results, set it to 0, 0
local RunService = game:GetService("RunService")

local Mover = {}
Mover.__index = Mover

function Mover.new(frame)
	local self = setmetatable({
		frame = frame,
		velocity = Vector2.new(0, 0),
		acceleration = Vector2.new(0, 0),
		position = frame.AbsolutePosition + offset
	}, Mover)
	
	return self
end

function Mover:Seek(goal: Vector2, speed: number, maxSteeringForce: number)
	RunService:BindToRenderStep("seek", 1, function()		
		goal = game:GetService("UserInputService"):GetMouseLocation() -- setting the goal to the mouse location
		
		local desiredVelocity = (goal - self.position).unit * speed -- calculating desired velocity
		local steeringForce = desiredVelocity - self.velocity -- calculating steering force
		
        -- clamping steering force using maxSteeringForce
		steeringForce = Vector2.new(math.clamp(steeringForce.x, -maxSteeringForce, maxSteeringForce), math.clamp(steeringForce.y, -maxSteeringForce, maxSteeringForce))
		
		self.velocity += steeringForce + self.acceleration -- apply the force
		self.position += self.velocity -- changing the objects position
		self.frame.Position = UDim2.new(0, self.position.x, 0, self.position.y)
	end)
end

return Mover
```

We take in three parameters. A goal, which the object will be moving to and a speed, which is how fast it'll reach the goal and the maxSteeringForce which defines how much force can be applied to the mover at maximum. We calculate Desired Velocity by normalizing the difference of the goal and the current position of the object and multiply it by the speed! Then we calculate the Steering force by the formula we saw above. This force is applied to the object, which changes its velocity, which further changes the object's position!

To test this out, every frame I set the goal to be the mouse's position on the screen! I have a circle on a canvas which will act as the Mover:
 
![image|690x333](upload://7StmXT5WTaFEwsV2mgnhgI8wGMD.png)

Here's the result!

![2L3u4vDuSZ (online-video-cutter.com)|video](upload://7TaTbeOy6I79VIKefsHn8Bcugpk.mp4)

<hr/>

### Flee Steering Behavior

In this gif, you can see how the object is fleeing from a point. Imagine this situation. You are in the middle of a car chase. Your car is being chased by another car. What will you do? Will you go towards the other car to flee from it? Of-course! Flee. Here's how you can simulate Flee Steering Behavior!

![](upload://zzRRSmK94Zx9brMTtOsP6wUtfoa.gif)

It is really simple, now that we have our seek function. You might laugh at this. But all you have to do is multiply the steeringForce with -1 to convert seek to flee.. Yeah..

![t1T3bN8Iy7 (online-video-cutter.com)|video](upload://jBDKgzxElQvWarHwBTJ5zfvdSiB.mp4)

Well.. that was fast. Guess the circle didn't like my mouse all this time.

### Arrival Steering Behavior

Imagine you driving a car on a highway, you see a big truck carrying logs about 200 m in front of you. To prevent crashing into the truck. You gradually apply breaks and after some time, come close to the truck. This is arrival. But what is the difference between Arrival and Seek? You might have noticed, in seek, the object never stops moving. It seeks a point endlessly. While in arrival, The object completely stops when it reaches the target!

How do we simulate arrival? Like we did for Seek. We move the object towards a point. But this time, we stop the object when it reaches the target and also reduce its speed on the way to the point! 

```lua
function Mover:Arrive(goal: Vector2, speed: number, maxSteeringForce: number, arrivalRadius: number) 
	RunService:BindToRenderStep("arrive", 1, function()		
		goal = game:GetService("UserInputService"):GetMouseLocation()

		local desiredVelocity = (goal - self.position).unit * speed 
		local steeringForce = desiredVelocity - self.velocity

		steeringForce = Vector2.new(math.clamp(steeringForce.x, -maxSteeringForce, maxSteeringForce), math.clamp(steeringForce.y, -maxSteeringForce, maxSteeringForce))
		
		if (goal - self.position).magnitude < arrivalRadius then -- if close the the point
			speed = speed * ((goal - self.position).magnitude / arrivalRadius) -- decreasing the speed of the object
		end
		
		self.velocity += steeringForce + self.acceleration
		self.position += self.velocity 
		self.frame.Position = UDim2.new(0, self.position.x, 0, self.position.y)
	end)
end
```

Here we take in another argument called Arrival Radius. If the object enters this radius, it's speed starts to deplete and eventually comes to rest.

![DhKrVuuu9Y (online-video-cutter.com)|video](upload://h6c81x8euwVl7Apeb7QyqLbYdVq.mp4)

<hr/>

### Pursue Steering Behavior

Pursuing is the process of following a target and aiming to catch it. Imagine yourself to be in a car chase again. But this time, you are the one chasing the other car. You get to know where the car is going to turn, to win the chase you take a shortcut straight towards the car!

[image](https://cdn.tutsplus.com/cdn-cgi/image/width=800/gamedev/authors/legacy/Fernando%20Bevilacqua/2012/11/30/pursuit_avoid_route.png)

![image|400x200](upload://r2qScsuf7RZllYiX0yNGikpMFsB.png)

How would we possibly simulate this?

We'll have two Movers this time. 1 will be the pursuer and the other the "target". The target will seek a different point, and the task of the pursuer is to pursue the target! To do this, we'll need to predict the target's position in the future. To do that, we'll use the target's current position and the target's velocity!

To calculate the desired velocity this time, we find the desired velocity for the predicted target position:

```lua
local desiredVelocity = ((target.position + target.velocity * 100) - self.position).unit * speed
```

[details="Client Testing Code"]
```lua
local Mover = require(Mover.module)

local newMover = Mover.new(path.to.pursuer)
local target = Mover.new(path.to.target)

target:Seek(Vector2.new(target.frame.AbsolutePosition.x, 100), 1, .1)
newMover:Pursue(target, 6, .1)
```
[/details]

And.. Lets take a look at how the mover pursues a target!

![cWXJeofz9q (online-video-cutter.com)|video](upload://fWraSV4NF3lR43uOs6KW5wd2X0p.mp4)

Amazing! The pursuer pursues the target by steering 100 pixels in front of the target in the direction the target is facing!

<hr/>

### Evade Steering Behavior

Its quite the opposite of Pursue. Instead of pursuing the target, we avoid it. And to do this, we simply multiply the desired velocity by -1, just how we did it for Flee.

![image|274x184](upload://8kAaqj5igIoGaFnCeMJZOQOX0Gu.png)


```lua
local desiredVelocity = ((target.position + target.velocity * 100) - self.position).unit * speed * -1
local steeringForce = (desiredVelocity - self.velocity) 
```

Lets see this in action:

![ael0qiqkSQ (online-video-cutter.com)|video](upload://1A7kWMGNsOL4DPKWAREHaLl7KVM.mp4)

You can see how its evading the target.

<hr/>

### Cleaning up messy code

Before we go onto combining steering behaviors to create something cool. We need to clean up this mess. 

This code is fine. I added speed and maxSteeringForce to the metatable to make things easier.

```lua
local RunService = game:GetService("RunService")

local Mover = {}
Mover.__index = Mover

function Mover.new(frame: Instance, maxSpeed: number, maxSteeringForce: number)
	local self = setmetatable({
		frame = frame,
		velocity = Vector2.new(0, 0),
		acceleration = Vector2.new(0, 0),
		position = frame.AbsolutePosition + offset,
        speed = maxSpeed,
        maxSteeringForce = maxSteeringForce
	}, Mover)
	
	return self
end

return Mover
```

Then, we create a new function named `:Steer()` which applies the steeringForce to the object:

```lua
function Mover:Steer(force)
	self.velocity += force + self.acceleration 
end
```

After we did this. Lets create function `:Update()`. This function runs every RenderStepped and updates the velocity and the position of the mover accordingly.

```lua
function Mover:Update()
	self.position += self.velocity 
	self.frame.Position = UDim2.new(0, self.position.x, 0, self.position.y)
end
```

Now we edit the Seek, Flee, Arrive, Evade and Pursue functions which instead of updating the velocity straight away, return the steering force: 

Here:

```lua
function Mover:Seek(goal: Vector2)
	local desiredVelocity = (goal - self.position).unit * self.speed
	local steeringForce = desiredVelocity - self.velocity
	
	steeringForce = Vector2.new(math.clamp(steeringForce.x, -self.maxSteeringForce, self.maxSteeringForce), math.clamp(steeringForce.y, -self.maxSteeringForce, self.maxSteeringForce))
		
	return steeringForce
end

function Mover:Flee(from: Vector2)
	return self:Seek(from, self.speed, self.maxSteeringForce) * -1
end

function Mover:Arrive(goal: Vector2, arrivalRadius: number) 
	if (goal - self.position).magnitude < arrivalRadius then
		self.speed = self.speed * ((goal - self.position).magnitude / arrivalRadius)
	end
	
	return self:Seek(goal, self.speed, self.maxSteeringForce)
end

function Mover:Pursue(target: Instance)
	local desiredVelocity = ((target.position + target.velocity * 100) - self.position).unit * self.speed
	local steeringForce = desiredVelocity - self.velocity
	
	steeringForce = Vector2.new(math.clamp(steeringForce.x, -self.maxSteeringForce, self.maxSteeringForce), math.clamp(steeringForce.y, -self.maxSteeringForce, self.maxSteeringForce))

	return steeringForce
end

function Mover:Evade(from: Instance)
	local desiredVelocity = ((from.position + from.velocity * 100) - self.position).unit * self.speed * -1
	local steeringForce = desiredVelocity - self.velocity

	steeringForce = Vector2.new(math.clamp(steeringForce.x, -self.maxSteeringForce, self.maxSteeringForce), math.clamp(steeringForce.y, -self.maxSteeringForce, self.maxSteeringForce))

	return steeringForce
end
```

Not only is it clean BUT also helps us combine different Steering Force to create cool simulations!

Final code:

```lua
local RunService = game:GetService("RunService")

local Mover = {}
Mover.__index = Mover

function Mover.new(frame: Instance, maxSpeed: number, maxSteeringForce: number)
	local self = setmetatable({
		frame = frame,
		velocity = Vector2.new(0, 0),
		acceleration = Vector2.new(0, 0),
		position = frame.AbsolutePosition + offset, 
		speed = maxSpeed,
		maxSteeringForce = maxSteeringForce
	}, Mover)
	
	return self
end

function Mover:Seek(goal: Vector2)
	local desiredVelocity = (goal - self.position).unit * self.speed
	local steeringForce = desiredVelocity - self.velocity
	
	steeringForce = Vector2.new(math.clamp(steeringForce.x, -self.maxSteeringForce, self.maxSteeringForce), math.clamp(steeringForce.y, -self.maxSteeringForce, self.maxSteeringForce))
		
	return steeringForce
end

function Mover:Flee(from: Vector2)
	return self:Seek(from, self.speed, self.maxSteeringForce) * -1
end

function Mover:Arrive(goal: Vector2, arrivalRadius: number) 
	if (goal - self.position).magnitude < arrivalRadius then
		self.speed = self.speed * ((goal - self.position).magnitude / arrivalRadius)
	end
	
	return self:Seek(goal, self.speed, self.maxSteeringForce)
end

function Mover:Pursue(target: Instance)
	local desiredVelocity = ((target.position + target.velocity * 100) - self.position).unit * self.speed
	local steeringForce = desiredVelocity - self.velocity
	
	steeringForce = Vector2.new(math.clamp(steeringForce.x, -self.maxSteeringForce, self.maxSteeringForce), math.clamp(steeringForce.y, -self.maxSteeringForce, self.maxSteeringForce))

	return steeringForce
end

function Mover:Evade(from: Instance)
	local desiredVelocity = ((from.position + from.velocity * 100) - self.position).unit * self.speed * -1
	local steeringForce = desiredVelocity - self.velocity

	steeringForce = Vector2.new(math.clamp(steeringForce.x, -self.maxSteeringForce, self.maxSteeringForce), math.clamp(steeringForce.y, -self.maxSteeringForce, self.maxSteeringForce))

	return steeringForce
end


function Mover:Steer(force)
	self.velocity += force + self.acceleration 
end

function Mover:Update()
	self.position += self.velocity 
	self.frame.Position = UDim2.new(0, self.position.x, 0, self.position.y)
end

return Mover
```

Testing it out:

```lua
local Mover = require(Mover.module)

local newMover = Mover.new(pursuer.frame,  5, .1)
local target = Mover.new(target.frame, 3, .1)

game:GetService("RunService").RenderStepped:Connect(function()
	local pursueSteeringForce = newMover:Pursue(target)
	local seekSteeringForce = target:Seek(game:GetService("UserInputService"):GetMouseLocation())
	
	newMover:Steer(pursueSteeringForce)
	target:Steer(seekSteeringForce)
	
	newMover:Update()
	target:Update()
end)
```

So we get the steering Force and then steer the movers accordingly.

You can see how I am controlling the red target with my mouse and the white pursuer is pursuing the target! Ooo, how helpful would this be for car chases! Might do a tutorial on that soon!

![fmASaqqGlQ (online-video-cutter.com)|video](upload://uewBNgUyZflrAITovKCL4znEVC0.mp4)

It. is. time.

### Grouping Steering Behaviors

It is time. We will now combine some of the Steering Behaviors to create the Grouping Steering Behavior.

Imagine yourself going to mcdonalds to buy a tasty burger. You see a huge line of people standing outside.

You'll notice, gradually the line gets bigger and bigger as many people come to the store. But the people in the front, who bought their burgers, move out. This, is grouping. Take this visual example:

![image|690x413](upload://clZsUiRYJgLuwO46mdktfmTek77.png)

How would we simulate this? We'll combine a few Steering Behaviors that we made and create this simulation!

Firstly lets understand how two different objects will steer towards the same direction:

![image|690x328](upload://46tVnNrq2xBu5jqHxUu5FFCv0mh.png)

Two movers with velocities v1 and v2 are moving in some direction. We need to adjust the velocity, such that both movers steer and move towards 1 direction.

We are basically seeking in to the same target. We'll be simulating the same with 8-10 movers that will be following the mouse IN A LINE without colliding! How interesting!

Firstly, we create a new function, lets call that `Assemble()` in a client script. 

```lua
local Mover = require(Mover.module)

local movers = {}

for _, obj in ipairs(parentOfMoverFrames:GetChildren()) do
	table.insert(movers, Mover.new(obj), 4, .1)
end

function Assemble()
	for _, mover in ipairs(movers) do
		local seekSteeringForce = mover:Seek(game:GetService("UserInputService"):GetMouseLocation())
		mover:Steer(seekSteeringForce)
		mover:Update()		
	end
end
	
game:GetService("RunService").RenderStepped:Connect(Assemble)
```

![image|690x335](upload://zLRH5i0LeIIdK1xXmyF3r8VxJf3.png)

I have eight of these movers seeking 1 single target. But when we run this, you'll notice that they just overlap each other.

![xzolF5XcCK (online-video-cutter.com)|video](upload://pitH0SbtCGQwSHiAlRn2BrEg2aw.mp4)

We need to detect collisions and slow the movers down accordingly.

To prevent them from overlapping, we'll need to check if the circles are in a given radius, if they are, we adjust their steeringForce.

```lua
function Assemble()
	for _, mover in ipairs(movers) do
		local frame = mover.frame
		
		for _, other in ipairs(movers) do
			if frame ~= other.frame then
				local radius = frame.AbsoluteSize.x/2 * 5 -- radius, 5 is some arbitrary value
				
				local center1 = frame.AbsolutePosition + frame.AbsoluteSize/2
				local center2 = other.frame.AbsolutePosition + other.frame.AbsoluteSize/2
				
				if (center2 - center1).magnitude < radius then -- if mover is in radius of another mover
					local diff = (center1 - center2).unit
					diff = diff/(center2 - center1).magnitude
					
					mover:Steer(diff) -- adjust its steer
				end
			end
		end
		
		local seekSteeringForce = mover:Seek(game:GetService("UserInputService"):GetMouseLocation())
		mover:Steer(seekSteeringForce)
		mover:Update()
	end
end
```

NOTE: this only works for perfect circles. For example a 40x40 circle which has a radius of 20.

Running this gives us the following, you can see how they are kinda keeping a distance between each other and moving in a line.

![3uV1roKJxF (online-video-cutter.com)|video](upload://5fKQUWfcDVWmgVIuTJIFUjIrXvQ.mp4)

There are several ways you could be doing this. If they are in a given radius, you can make them Flee the other mover. But that may not give perfect results. You can use Pursue to adjust their positions as well! You can even give them an eyesight using [RayCast2](https://github.com/jaipack17/RayCast2/blob/main/RayCast2.lua) and steer them accordingly!

This was a very basic example of how grouping works. You'll notice that we aren't taking care of who comes first in the group, and that is a flaw, since this tutorial is quite big, I'll leave that for you to solve! You can possibly make Pursue to come in use of this! This is how you can combine certain Steering Behaviors to make stuff like this!

You can even create stuff like this, using Steering Behaviors, although this isn't made with Steering Behaviors but you surely can! 

![collision response ‐ Made with Clipchamp (2)|video](upload://duPDDdVzAqXMlfz60hng99ALJtA.mp4)

**[Also read](https://devforum.roblox.com/t/introduction-to-steering-behaviors/1441680/3)**

<hr/>

## Conclusion

I hope you understood what Steering Behaviors are and how you can script them in roblox to make awesome stuff. I hope this helped, have fun! :+1:.
