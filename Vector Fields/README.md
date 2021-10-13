<div align="center">
    <h1>Vector Fields</h1>
</div>
<hr/>
<img align="left" src="https://user-images.githubusercontent.com/74130881/136701095-e8d9e525-e933-4e8a-86f7-61b70065d49b.png" width="360px" height="250px" /> Let's talk vectors today, specifically vector fields. As many of you may know, a vector has both a direction and a magnitude. You may already have used vectors in game development, programming and mathematics in general. Take a look at the image on the left to have a better understanding of a vector. Vector fields if not grids, but are a group of points in uniform order that are assigned different vectors. These points act as the 'tail' or the 'starting point' of the vector. These vectors are generalized and visualized as arrows with a direction and a magnitude.
<br/><br/>
Vector fields are used for several purposes, usually to have an understanding of the movement of fluid particles, gravitational forces, magnetic forces and atmospheric pressure. Today, We'll be looking at static vector fields portraying fluid flow. 

# Static Vector Fields

Static vector fields are essentially vector fields whose vectors never change/are fixed. These fields are the representation of functions with same dimensions of their results and their parameters. Let's imagine, points in a uniform order are spread on a cartesian plane. These points mark tails (starting point) of vectors spread over the plane. To determine the direction and magnitude of these vectors, we'll write an arbritary function which takes in x and y (point). This function then produces an output which will be the direction of the vector. Let's take an easy to evaluate function to really get the hang of it. 

<img src="https://user-images.githubusercontent.com/74130881/137094540-d90dcf75-1898-447b-9d02-155d4a13f99b.png" width="300px" />

Here's a simple function. For any value of x and y, the head of the vector will be *(x + 1, 2y - 1)*. Let's say x and y are 0, the origin. To find the tail of the vector, we'll need to use the function above. x + 1, is 0 + 1, and 2y - 1 is 2 * 0 - 1. This results in (1, -1), which is the head of our vector. Let's take another example. Let the point be (2, 2). The resulting head would be (3, 3) and so on. Our vectors appear to be like this on the cartesian plane.

<img src="https://user-images.githubusercontent.com/74130881/137096307-6ccf060a-f86e-4d8b-9cc9-409568567794.png" width="250px" />

If we certainly use the same function for a grid of points, we'll ultimately get a vector field as a result. Let's try that on a 6x6 grid on the cartesian plane. Here's the result! Our vector field. 

<img src="https://user-images.githubusercontent.com/74130881/137100573-ba51ec5c-bb5c-4d27-bac7-f882b425b9bc.png" width="300px" />

Cool isn't it? You may have noticed that the longer vectors tend to clutter the vector field. If a the grid is enlarged and the number of vectors is increased, the vector field will be a complete mess. To counter this, we could artificially shorten the length of these vectors. To distinguish between long and short vectors, as many say, we can add color coding to the vectors, but that isn't necessary. 

Next up, we'll be looking into fluid particles! We'll be associating each point on a vector field as a fluid particle, this fluid particle will have some sort of vector connected to it which will be used to portray the flow of fluid particles. 

# Divergence

Let's dive into the fluid we'll be creating a vector field of. We'll create a **static** vector field of the flow of fluid particles. Note that we'll keep uniform lengths of the vectors. Firstly, we'll define the points on a grid. These points will be the particles of the fluid. 

```lua
local viewport = workspace.CurrentCamera.ViewportSize
local width = viewport.x 
local height = viewport.y

local grid = Vector2.new(20, 10)
local gapX = width/grid.x 
local gapY = height/grid.y

local particles = {}

for i = 1, grid.X - 1 do 
	for j = 1, grid.y - 1 do 
		table.insert(particles, Vector2.new(i * gapX, j * gapY))
	end
end
```

If you go ahead and render these points on the screen, they look something like the following:

![image](https://user-images.githubusercontent.com/74130881/137110602-14ac0083-c34f-4dfa-8eb4-3d01aed2e5c9.png)

Now that we have a grid of fluid particles, its time we understand what divergence really is. 
