<div align="center">
    <h1>Separating Axis Theorem</h1>
    <p>Detecting and Responding to collisions on a 2 dimensional plane</p>
</div>
<hr/>

In game development and computer graphics, one of the trickiest problem is simulating Collisions between two arbritary elements. Many find collision detection to be fairly easy (which is justified), but fail to simulate elastic collision responses. In this article, we'll look into a mathematical theorem which goes by the name of "Separating Axis Theorem". Some of the other articles over here, or even my custom physics engine uses this theorem to detect and respond to elastic collisions. 

The theorem states that two bodies don't collide, as long we are able to put a straight line between the two, that doesn't intersect either body. This should be easy to make the use of, but there is a downside to it. While it may be performant, it works only for Convex Shapes. If either of the body was a Concave shape, this theorem won't be too accurate with collision detection. The image below should clear it up for you.

![image](https://user-images.githubusercontent.com/74130881/134708625-09b4789d-98ae-4d71-92c6-06b2e66e43a0.png)

In Figure 1, both bodies are Convex polygons and do not collide. While, in Figure 2, one of the bodies is a Concave polygon. Both bodies appear to be free of any collisions but since the line intersects 1 of the bodies by this theorem, they are said to be colliding even though they are not. This shouldn't be too big of a problem unless its a large scale project. 

Now onto detecting collisions. We use something called a 'projection' of the two bodies. Let there be another line named the 'axis' which is perpendicular to the Separating line (line in between the two bodies). We can now project the bodies onto this perpendicular. IF the separating line intersect either of the projections, the bodies are said to be colliding. We do not need to worry about where we create the project (left or right), since the projection ultimately is no longer 2 dimensional, rather 1 dimensional. 

![Webp net-resizeimage](https://user-images.githubusercontent.com/74130881/134713214-3a85a3b0-b237-42fa-a90e-93b9a26c1fce.png)

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

![image](https://user-images.githubusercontent.com/74130881/134716839-dd860173-66d9-4ac8-91c5-e486fbbb10f2.png)

All that is left for Collision detection is loop through the edges of the bodies, calculating the axis to project the points on, based on the endpoints of the edge, project the points on the axis, and simply checking if the projections overlap each other i.e the separating line intersect either of the projections.

The function below simply returns a boolean which is either true or false. It returns true if they are colliding, else false. We loop through the edges of the bodies, calculate the axis using the end-points of the edge. Then we project both bodies onto the axis, and the last step would be to check whether they collide or not! To do that, we find the amount of area (in 1 dimension) that is covered by the overlapping of both projections i.e the interval distance! If, the interval distance is greater than 0, they do collide which is justified. Else, they do not collide!

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
          return true
      end

      return false
   end
end
```

![image](https://user-images.githubusercontent.com/74130881/134718512-05621f39-70b6-4741-b6b8-4b5bb1b1588c.png)


