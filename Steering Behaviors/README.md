<div align="center">
   <h1>Steering Behaviors</h1>
   <p>Steering Behaviors For Autonomous Characters</p>
</div>

<hr/>

## Table of Contents
* [Preface - What are Steering Behaviors?](#preface---what-are-steering-behaviors)
* [Coding Steering Behaviors](#coding-steering-behaviors)
    * [Seek Steering Behavior](#seek-steering-behavior)
    * [Flee Steering Behavior](#flee-steering-behavior)
    * [Arrival Steering Behavior](#arrival-steering-behavior)
    * [Pursue Steering Behavior](#pursue-steering-behavior)
    * [Evade Steering Behavior](#evade-steering-behavior) 
    * [Wander Steering Behavior]()
    * [Cleaning up messy code](#cleaning-up-messy-code)
    * [Grouping Steering Behaviors](#grouping-steering-behaviors)
* [Conclusion](#conclusion)

<hr/>

# Preface - What are Steering Behaviors?

When it comes to moving characters, objects, vehicles and other autonomous objects in a natural and realistic fashion, we use Steering Behaviors. In the early 1990s, computer scientist [Craig Reynolds](http://www.red3d.com/cwr) developed algorithmic steering behaviors for autonomous agents. These behaviors allowed individual elements to navigate their digital environments with strategies for seeking, fleeing, wandering, arriving, pursuing, evading, avoiding an obstacle, following a path. 

Steering behaviors help us control objects in the world like actual human beings. The ability to give objects human like physics and eyesight is a huge deal and a fascinating concept for many. These steering behaviors are tricky to crack but with the help of RayCasting and a few algorithms by Craig Reynolds, we can together figure them out! Today we'll be taking a peak inside these Steering Behaviors and making something cool!

![flock](https://github.com/jaipack17/write-ups/blob/main/Steering%20Behaviors/assets/flock.gif?raw=true)

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

![seek and flee](https://github.com/jaipack17/write-ups/blob/main/Steering%20Behaviors/assets/seek%20and%20flee.gif?raw=true)

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

![image|690x163](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/8/5/1/8512039ac09458f19ca005f1caa8b358fc7ee3a2.png)

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
 
![image|690x333](https://doy2mn9upadnk.cloudfront.net/uploads/default/optimized/4X/3/7/3/3737980ecbfb257cf043129dcaa1db329e16c6ef_2_1035x499.png)

Here's the result!

https://user-images.githubusercontent.com/74130881/134693799-36d9b2e6-7583-436f-9b5d-195e33e3da6a.mp4

<hr/>

### Flee Steering Behavior

In this gif, you can see how the object is fleeing from a point. Imagine this situation. You are in the middle of a car chase. Your car is being chased by another car. What will you do? Will you go towards the other car to flee from it? Of-course! Flee. Here's how you can simulate Flee Steering Behavior!

![seek and flee](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/f/9/5/f95a127cf990a82a51e778d5da35b7d2e26808ae.gif)

It is really simple, now that we have our seek function. You might laugh at this. But all you have to do is multiply the steeringForce with -1 to convert seek to flee.. Yeah..

https://user-images.githubusercontent.com/74130881/134692987-da2be6c4-11bf-48f4-8e9c-2f5a788ce0f2.mp4

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

https://user-images.githubusercontent.com/74130881/134693129-e5b313f6-010d-4ef3-80ac-0160cecb3283.mp4

<hr/>

### Pursue Steering Behavior

Pursuing is the process of following a target and aiming to catch it. Imagine yourself to be in a car chase again. But this time, you are the one chasing the other car. You get to know where the car is going to turn, to win the chase you take a shortcut straight towards the car!

[image](https://cdn.tutsplus.com/cdn-cgi/image/width=800/gamedev/authors/legacy/Fernando%20Bevilacqua/2012/11/30/pursuit_avoid_route.png)

![image|400x200](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/b/d/8/bd811dffdeb1b8c55f1c62dcdd4328c1d7ca28a1.png)

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

https://user-images.githubusercontent.com/74130881/134693229-1aee905f-1379-4dbc-af43-f904f9779c49.mp4

Amazing! The pursuer pursues the target by steering 100 pixels in front of the target in the direction the target is facing!

<hr/>

### Evade Steering Behavior

Its quite the opposite of Pursue. Instead of pursuing the target, we avoid it. And to do this, we simply multiply the desired velocity by -1, just how we did it for Flee.

![image|274x184](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/3/a/6/3a6509f57348d311c6ca09832baff29d42fcf912.png)


```lua
local desiredVelocity = ((target.position + target.velocity * 100) - self.position).unit * speed * -1
local steeringForce = (desiredVelocity - self.velocity) 
```

Lets see this in action:

https://user-images.githubusercontent.com/74130881/134693321-36d27326-983e-4b7a-af49-49309caf07c6.mp4

You can see how its evading the target.

<hr/>

### Wander Steering Behavior
This steering behavior is extremely helpful for simulating cars and npcs that walk in random directions. In this steering behavior. A random target is chosen in a given radius, some pixels ahead of the direction an object is facing. The object then seeks this target which results in a smooth simulation of this steering behavior.

![6zMEXUL7CS (online-video-cutter.com)|video](upload://ad7IU4iXsuJLsqOWT6NJnx7tYFy.mp4)
![Uzl5vI3d15 (online-video-cutter.com)|video](upload://8uipke7VfXdAXCIpI7ZzfJK3vAa.mp4)

https://user-images.githubusercontent.com/74130881/134693357-2da69ed7-79dd-4bff-ad9a-4fd010a798ba.mp4
https://user-images.githubusercontent.com/74130881/134693365-c92f0606-34cb-4b75-a0c4-8b015e92cb6e.mp4

How this works:

There's an initial angle to the red circle. A random angle is chosen, the white circle you see ahead of the red circle is the radius inside which the targets are chosen. This radius is found using the velocity of the red circle and the chosen angle. A target inside this is chosen and the red circle is asked to seek this target. The cyan point you see on the white circle's circumference locates the direction of the steering force.

uncopylocked place:

https://www.roblox.com/games/7351301290/Wander-Steering

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

https://user-images.githubusercontent.com/74130881/134693412-5409f6a4-2987-4b08-b403-e4faaf49837e.mp4

It. is. time.

### Grouping Steering Behaviors

It is time. We will now combine some of the Steering Behaviors to create the Grouping Steering Behavior.

Imagine yourself going to mcdonalds to buy a tasty burger. You see a huge line of people standing outside.

You'll notice, gradually the line gets bigger and bigger as many people come to the store. But the people in the front, who bought their burgers, move out. This, is grouping. Take this visual example:

![image|690x413](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/5/6/9/56967b1b0c28dd6926506062cd5a1ff294cccf89.png)

How would we simulate this? We'll combine a few Steering Behaviors that we made and create this simulation!

Firstly lets understand how two different objects will steer towards the same direction:

![image|690x328](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/1/c/c/1cc44b132eaf31e0575d7b297dcde4dd21e9a46d.png)

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

![image|690x335](https://doy2mn9upadnk.cloudfront.net/uploads/default/optimized/4X/f/a/b/fab5401ded584e98e380b31af6ad13103d4e1e21_2_1035x502.png)

I have eight of these movers seeking 1 single target. But when we run this, you'll notice that they just overlap each other.

https://user-images.githubusercontent.com/74130881/134693578-a6c14c4b-8f5f-4ebb-826e-fe648eb706ac.mp4

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

https://user-images.githubusercontent.com/74130881/134693597-031c507e-89b5-40a7-a0a5-e2d4c872ed23.mp4

There are several ways you could be doing this. If they are in a given radius, you can make them Flee the other mover. But that may not give perfect results. You can use Pursue to adjust their positions as well! You can even give them an eyesight using [RayCast2](https://github.com/jaipack17/RayCast2/blob/main/RayCast2.lua) and steer them accordingly!

This was a very basic example of how grouping works. You'll notice that we aren't taking care of who comes first in the group, and that is a flaw, since this tutorial is quite big, I'll leave that for you to solve! You can possibly make Pursue to come in use of this! This is how you can combine certain Steering Behaviors to make stuff like this!

You can even create stuff like this, using Steering Behaviors, although this isn't made with Steering Behaviors but you surely can! 

https://user-images.githubusercontent.com/74130881/134693653-176972f6-2e01-4b74-8c37-44f82ae23a40.mp4

<hr/>

## Conclusion

I hope you understood what Steering Behaviors are and how you can script them in roblox to make awesome stuff. I hope this helped, have fun!
