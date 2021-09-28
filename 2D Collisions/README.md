<div align="center">
    <h1>Two Dimensional Collisions</h1>
    <p>Its fundamentals and Techniques</p>
</div>
<hr/>

In game development and computer graphics, one of the trickiest problem is simulating Collisions between two arbritary elements. Many find collision detection to be fairly easy (which is justified), but fail to simulate elastic collision responses. This has been talked upon several times on the web but there isn't quite an answer or the answer is quite vague. The aim of this post is to elucidate the fundamentals of collision detection and response, its various techniques and logic. 

We'll discuss various techniques of detecting and responding to collisions, but in order to keep a balanced flow in learning, we'll start off with fairly simple stuff and gradually step up to advanced techniques. 

I won't go in depth to the scripting parts since that's something for you to work upon! Don't worry though, I do provide pseudocode and code for stuff that you may get stuck upon or don't quite know how to translate to code. 
<hr/>

# One Dimensional Collisions

Before we steer towards two dimensional collisions, I'd like to take some time to explain One dimensional collisions based on just left and right, or up and down directions. We'll look into collisions both on X and the Y axis individually here. To keep this easy to understand, we'll take two examples. Circle to Circle collisions and Square to Square collisions. Towards the end of the post we'll look into an advance theorem which is used to simulate collisions for all sorts of convex polygons.

Lets start with Circle to Circle collisions. To detect collisions between the two, we'll use a standard method that's widely used in development. As you know, the distance from the Center to the boundary of the circle is equal to its radius. To detect collisions between the two all we need to check is, if the distance between the centers of the two circles is less than the sum of the radiuses of both circles, if yes then the two circles are said to be colliding. Its that simple!

![image](https://user-images.githubusercontent.com/74130881/135019216-e20faabe-5e7b-41f8-84b5-0fdeeaaf86d9.png)

Collision response is nothing but what we do after we have checked if the two circles are colliding. This can be carried out by different ways here. Thankfully, if the masses of both circles are equal, all we have to do is interchange the velocities of the circles. In the other case, if the masses of both circles are different. We use the standard equation of Newton's 3rd law of motion to find the velocities of both circles after collision.

![image|343x91](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/3/a/0/3a085a92dbb3498825d9d0f6cb11c79bfcfee685.png)

![image|352x70](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/6/a/e/6aec5cb7f6eadb5c5b0990051bba666a93e3bccc.png)

This method is generally used to simulate natural elastic collisions, but if you'd like to go for a more game like collision simulation. You could use another way to repond to these collisions. We use the same old method to detect collisions but we'll return some additional information rather than just a boolean. We'll return the magnitude of the area where both circles overlap, moreover the Collision penetration depth.

![image|196x196](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/0/1/8/018855c615ea308f3431a0d4d460ca8eb3968e02.png)

We can write it in the form of pseudocode as:

```lua
function DetectCollision(c1, c2) -- parameters contain our circles
    if (c2.center - c1.center).magnitude < (c1.radius + c2.radius) then
     
        centerDifference = c2.center - c1.center
        distance = centerDifference.magnitude

        CollisionInfo = {
            depth = (c1.radius + c2.radius) - distance
        }
        
        return CollisionInfo
    end

    return nil -- no collisions
end
```
We can now use this depth to simulate collision response. All we have to do is apply certain force to the circles to separate them. We can thus say, Velocity = Velocity + depth/2 * spring

We can apply the same equation for both circles in opposite directions and they'll eventually be separated. Note that Velocity consists only of the X value and not Y. spring is  a multiplier here. The smaller its value, the smaller the separating force and vice-versa. 

[Media Source](https://teaching.smp.uq.edu.au/scims/Calculus/Collisions.html)

![gif](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/1/b/2/1b23df8817f886723aa23ecac431e5fc5b8c9b3d.gif)

That's it for 1 Dimensional Circle to Circle collisions. Square to Square collisions won't take much time since we already have a base setup. 

<hr/>

Stepping further to 1D Square to Square collisions. For detecting collisions, we could have something to do with the length of the side and the top left corner of the square? Isn't it? Lets have a look. 

If we know the Top Left corner of each square. (In our case, the AbsolutePosition) and the length of  a side of the square (AbsoluteSize.X or AbsoluteSize.Y) we should be able to get the Collision Penetration depth like we did for the Circles (but with a twist) and apply the forces accordingly. 

We could see if they collide by checking if the SquareB.TopLeft.X is less than SquareA.TopLeft.X + Side.Length and vice-versa!

![image|690x370](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/3/b/e/3be37d03444dbdaaa708339240ec887370accf68.png)

We can write it down as:

```lua
function DetectCollision(A, B)
    if (B.AbsolutePosition.x <= A.AbsolutePosition.x + A.AbsoluteSize.x) then 
        return true -- colliding
    end

    return false
end
```

Responding to collisions shouldn't be hard at all. We discussed earlier how we can use conservation of momentum to respond to collisions or use the Collision Penetration depth to separate the bodies from each other! That's for you to experiment with! We'll look into 2 dimensional collisions now.

<hr/>

# Boundary Collisions

Beginning with 2D collisions, I'd like to discuss the most basic method of responding to collisions. Every object on the screen is in an enclosed space, and we obviously wouldn't want our objects going beyong that enclosed space when in motion. We use a common method to keep them in the enclosed space:

We check if the body comes in contact with any boundary of the screen, the top, bottom, left and right edge. If it does, first we correct the body's position. And by that I mean, if the body goes past the edge, we bring the body back in the enclosed space, and then all we do is reverse X or Y coordinate of the body's velocity depending upon the edge it collides with! If it collides with the top or bottom edge, we reverse velocity.y, else we reverse velocity.x! The figure below shows the change in the object's velocity when it collides with the left edge of the screen

![image|690x360](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/5/8/d/58dcdaf2869bc7b34b8a4a3a53461d7c301c1ab9.png)

We'll take a simple example of a circle and the left edge. Let's write it down in the form of code!

```lua
function BoundaryCollisions(body)
     local width = workspace.CurrentCamera.ViewportSize.x
     local height = workspace.CurrentCamera.ViewportSize.y

     -- Body has a radius, center position and a velocity
 
     -- left edge
     if (body.position.x - body.radius <= 0) then
         body.position = Vector2.new(0 + body.radius, body.position.y) -- correcting the position
         body.velocity = Vector2.new(body.velocity.x * -1, body.velocity.y) -- reverse velocity
     -- Right edge
     elseif (body.position.x + body.radius >= width) then
         body.position = Vector2.new(width - body.radius, body.position.y)
         body.velocity = Vector2.new(body.velocity.x * -1, body.velocity.y)
     end
      
     -- Top edge
     if (body.position.y - body.radius <= 0) then
         body.position = Vector2.new(body.position.x, 0 + body.radius)
         body.velocity = Vector2.new(body.velocity.x, body.velocity.y * -1)
     -- Bottom edge
     elseif (body.position.y + body.radius >= height) then  
         body.position = Vector2.new(body.position.x, height - body.radius)
         body.velocity = Vector2.new(body.velocity.x, body.velocity.y * -1)            
     end
end
```
![ezgif.com-gif-maker (9)|600x308](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/0/8/5/0853635890013b71613b31521e55c159ca38e7ec.gif)

Look's nice, if it was a square, you would have to do the following:

Left edge: if square.TopLeft.x <= 0
Right edge: if square.TopLeft.x + square.sideLength >= width
Top edge: if square.TopLeft.y <= 0
Bottom edge: if square.TopLeft.y + square.sideLength >= height

If it was a different shape, you'll have to check for edge of the body and the screen edge, if they intersect each other, you'll have to calculate the velocities accordingly. We'll look into this further in the tutorial. 

This could be helpful to create pong games **`:)`**

<hr/>

# 2D Circle Collisions

Thankfully, it isn't as hard as you thought it is! Initially we discussed about one dimensional circle collisions, well, its the same! But here, the velocity will have to do with both x and y axes! You might have seen one of my devlogs on a physics engine I was making, it looked something like this:

https://user-images.githubusercontent.com/74130881/135019742-4b52fd16-d250-4759-b0c4-7d755aba05cd.mp4

Now here, you may notice, a gravitational force is applied on the bodies pulling them towards the ground. The problem with the formula we used to respond the collisions won't work with gravitational forces or any external forces acting on the ball since we ignore those forces when calculating the final velocities of the ball. To counter this problem, I used trigonometry! 

I used the same method we learnt about earlier to check if two circles collide, for the collision response I expect you to have knowledge about trignometry, so here we go! We first start by finding the difference in the positions of the two circles. c1 and c2 are the two circles. We then find the tangent inverse square where we pass in d.y and d.x. Then we find the target to which c2 would end up going towards. And after that we find the acceleration (spring acts as a multiplier force) which is then added to the velocities of the circles in opposite directions!

```lua
local d = c1.position - c2.position 
local minMag = c1.radius + c2.radius

local theta = math.atan2(d.y, d.x)
local targetX = c2.position.x + math.cos(theta) * minMag
local targetY = c2.position.y + math.sin(theta) * minMag
				
local accX = (targetX - other.position.x) * spring
local accY = (targetY - other.position.y) * spring
				
c2.velocity = c2.velocity - Vector2.new(accX, accY)
c1.velocity = c1.velocity + Vector2.new(accX, accY)
```
You must be tired of me using circles to simulate collisions right? Its time to spice things up. We're are now going to use bodies with multiple edges! We'll discuss about the Separating Axis Theorem next.

# Separating Axis Theorem

**You'll need to know Vector Math operations like Dot Products in order to understand stuff below clearly; I recommend you watch [this video on Dot Products by EgoMoose](https://www.youtube.com/watch?v=QtsbayXxPIA&ab_channel=EgoMoose)**

We'll look into a mathematical theorem which goes by the name of "Separating Axis Theorem". Some of the other posts over here, or even my custom physics engine uses this theorem to detect and respond to elastic collisions. 

The theorem states that two bodies don't collide, as long we are able to put a straight line between the two, that doesn't intersect either body. This should be easy to make the use of, but there is a downside to it. While it may be performant, it works only for Convex Shapes. If either of the body was a Concave shape, this theorem won't be too accurate with collision detection. The image below should clear it up for you.

![image](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/d/4/e/d4e9569ffd6db3029cc3c27f687263d9f20d3eeb.png)

In Figure 1, both bodies are Convex polygons and do not collide. While, in Figure 2, one of the bodies is a Concave polygon. Both bodies appear to be free of any collisions but since the line intersects 1 of the bodies by this theorem, they are said to be colliding even though they are not. This shouldn't be too big of a problem unless its a large scale project. 

Now onto detecting collisions. We use something called a 'projection' of the two bodies. Let there be another line named the 'axis' which is perpendicular to the Separating line (line in between the two bodies). We can now project the bodies onto this perpendicular. IF the separating line intersect either of the projections, the bodies are said to be colliding. We do not need to worry about where we create the project (left or right), since the projection ultimately is no longer 2 dimensional, rather 1 dimensional. 

![Webp net-resizeimage](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/6/7/4/674de2e887b0bc9db8d411bb506bbb4f82bae2ed.png)

The pseudocode (lua) below is used to make the projection of a body onto the Axis. `vertices` is the array containing all verticies of the body. We loop through each point and project it to the axis. `min` and `max` values are set to be the dot product of the Axis and the Vertex after being compared to already existing min and max values. We then update min and max values to appropriate results of the projection. In every case, the 2 points farthest to each other are projected. Or in short, the projection in 2 dimensions is the dot product of the projection axis and the vertex we project.  

```lua
function CreateProjection(Axis) 
	local dot = Axis.x * vertices[1].pos.x + Axis.y * vertices[1].pos.y;

	local min, max = dot, dot;

	for i = 2, vertexCount, 1 do
		dot = Axis.x * vertices[i].pos.x + Axis.y * vertices[i].pos.y;

		min = math.min(dot, min)
		max = math.max(dot, max)
	end
	
	return min, max
end
```

![image](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/3/a/7/3a7d04a33d652c48663d2e64fc968552dda1b739.png)

All that is left for Collision detection is loop through the edges of the bodies, calculating the axis to project the points on, based on the endpoints of the edge, project the points on the axis, and simply checking if the projections overlap each other i.e the separating line intersect either of the projections.

The function below simply returns a boolean which is either true or false. It returns true if they are colliding, else false. We loop through the edges of the bodies, calculate the axis using the end-points of the edge. Then we project both bodies onto the axis, and the last step would be to check whether they collide or not! To do that, we find the amount of area (in 1 dimension) that is covered by the overlapping of both projections i.e the interval distance! If, the interval distance is greater than 0, they do not collide which is justified. Else, they do collide!

```lua
function Colliding(body1, body2)
   for e of body1 and body2 do
      local Axis = Vector2.new(e.point1.pos.y - e.point2.pos.y, e.point2.pos.x - e.point1.pos.X).unit 

      local minA, maxA = body1:CreateProjection(Axis)
      local minB, maxB = body2:CreateProjection(Axis)

      local magnitude;
      if minA < minB
	      magnitude = minB - maxA;
      else
	      magnitude = minA - maxB;
      end
      
      if magnitude > 0 then
          return false
      end

      return true
   end
end
```

![image](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/0/d/b/0dbd4ad8d8e7bce8e10f4c2abb2ee043457cd38c.png)

We know if the two bodies collide with each other, but how exactly do we respond to this collision and separate them from each other? We'll make the use of The Penetration Depth of the collision and return crucial information which we can use to separate the two shapes! We can further edit the code to say the following:

minimumMagnitude is the same as `math.huge` initially and we define its value before looping through each edge and processing our checks. We then find the minimum Interval Distance of all, we update the axis to which the projection was made on and update the edge whos points were projected on the axis! (Edge which is said to be colliding)
```lua
local info = {}

if magnitude > 0 then
     return; -- return nothing, no collisions
else 
     if math.abs(magnitude) < minimumMagnitude then
            minimumMagnitude = math.abs(magnitude)
			info.axis= Axis
			info.edge = e
     end
end
```

The next step would be to set the Collision Pentration depth which can be done by saying `info.depth = minimumMagnitude` after we have the minimumMagnitude set to a valid number. Note: The depth is a scalar quantity. 

Further ahead, we find the dot product of the Axis and the difference between the Center position of the two bodies. If the dot product is less than 0, we reverse the Axis by multiplying it by -1. The next step would be the calculate the vertex which was in collision with the edge we found above. Note that the edge and the vertex belong to different bodies. We can do that by looping through the vertices of the body to which the colliding edge DOES NOT belong to, finding the dot product of the difference between the position of the vertex and the center of the other body. We find the minimum dot product of all and find the vertex which was the nearest to the other body when they were colliding.

```lua
local minimumDot = math.huge

for _, v in ipairs(body1.vertices) do 
    local dist = info.axis:Dot(v.pos - body2.center)
    if dist < minimumDot then
        info.vertex = v
        minimumDot = dist
    end
end
```

We now have the following information which will help us in responding to the collision!

* Are the two bodies colliding?
* Collision penetration depth
* Vertex involved in the collision
* Edge involved in the collision
* Axis of the final projection

Onto collision response, we can use the information above to separate both bodies from each other:

In order to get the 2D data of the Collision Penetration depth, we multiply the axis with the depth we calculated above. To move the vertex we'll simple add Half the penetration vector to the position of the vertex. 

```lua
info.vertex.pos += penetrationVector/2
```

For moving the edge, we'll first need to find the closest point of the edge to the vertex of the other body! Reason being, we'll move the vertices of the edges, to simulate natural collisions, if the vertex collides with the edge while being closer to the "bottom/second" vertex of the edge, more force will be applied to the bottom vertex of the edge! Here's a little example of what I mean by the same.

![image|690x340](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/5/4/4/544f7473ba4f5a1aa6ae6c0ba81bfb447815fce7.png)

We can do that by the standard equation:

![image|86x51](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/7/e/a/7eacff3e312943c5385127280641fac2d85bac1e.png)

t is a percentage value of a point which lies on the edge depicting where the vertex collides with the edge. E1 and E2 are vertices of the edge and V is the vertex of the other body. This is related to Linear Interpolation. Lets jot the above into code:

```lua
local E1 = info.edge.point1
local E2 = info.edge.point2

local t;
if math.abs(E1.pos.x - E2.pos.x) > math.abs(E1.pos.y - E2.pos.y) then
	t = (info.vertex.pos.x - penetrationVector.x - E1.pos.x)/(E2.pos.x - E1.pos.x)
else 
	t = (info.vertex.pos.y - penetrationVector.y - E1.pos.y)/(E2.pos.y - E1.pos.y)	
end
``` 

Using the t value we can calculate a scaling factor that ensures that the collision vertex lies on the collision edge after the collision response. Using:

![image|115x55](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/5/0/0/5006671cc40b99967e05a4015d9b7ae72c3654bc.png)

Then move the vertices of edges according to the factor. Half the force is applied in the opposite direction (of the force applied to the vertex of the other body)

```lua
local factor = 1/(t^2 + (1 - t)^2);
E1.pos -= CollisionVector * ((1 - t) * factor/2)
E2.pos -= CollisionVector * (t * factor/2)
```

That's it! You now have smooth collisions between rigid bodies with 'n' number of sides!

https://user-images.githubusercontent.com/74130881/135019871-1b7bcea5-d3da-4b78-bf18-6ddd4c5edd9d.mp4

Once again, it is important to note that this would work accurately only for convex shapes, if you end up using concave shapes, the algorithm would end up using them as convex shapes:

![image|690x261](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/b/e/e/beede7d71549f86387a6977c56546265a86e1311.png)

In order to add concave shapes support, you'll have to figure out an algorithm which divides a single body into different segments. 

![image|690x294](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/c/d/9/cd9db902df95d2c9b3c0dab51626461eadb6226f.png)

After dividing them into different convex bodies, we can run the same checks we did above and find out if two bodies collide or not!

<hr/>

# Debugging Collisions

Something that many of you may notice while playing around with collisions and other such simulations is that, when an object collides with another, or the boundaries of the screen at high velocity/speed or if too many collisions take place, the object ends up completely going through the other entity, which creates sloppy simulations at lower frame rate and sometimes even at high frame rates! 

This happens when we miss the point when a collision takes place, i.e collisions that take place between two rendered frames on the screen.

To fix this, we use something called a "time step". Instead of checking **once** every RenderStepped for collisions, we try detecting collisions multiple times in 1 single frame. The amount of timeSteps is completely arbitrary.

```lua
let timeSteps = 10

local function Draw()
    for i = 1, timeSteps do
        -- handle collisions
        -- render objects
    end
end

game:GetService("RunService").RenderStepped:Connect(Draw)
```
Let's take an example, here's a comparison of a lot of collisions are taking place at moderate speed with and without timesteps.

**Without timsteps:**

![ezgif.com-gif-maker (10)|600x143](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/7/9/2/792fce3c5224a72d9248b5d9c8117c62bbc032e9.gif)

**With timesteps:**

![ezgif.com-gif-maker (12)|600x143](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/5/4/0/54034ba0c4ddc082ddb03cca6e82feca8bc37b11.gif)

<hr/>

# Conclusion

I would like to list other resources that would help you understand more about collisions. Be sure to check these out someday!

* [2D Collision Detection - Nilson Souto](https://www.toptal.com/game/video-game-physics-part-ii-collision-detection-for-solid-objects)
* [Verlet Integration along with Separating Axis Theorem - Myopic Rhino](https://www.gamedev.net/articles/programming/math-and-physics/a-verlet-based-approach-for-2d-game-physics-r2714/)
* [Dot Products - EgoMoose](https://www.youtube.com/watch?v=QtsbayXxPIA&ab_channel=EgoMoose)
* [Collision Detection & Response - Reducible](https://www.youtube.com/watch?v=eED4bSkYCB8&ab_channel=Reducible)

Thanks for reading.
Have a great day!
