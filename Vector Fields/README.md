<div align="center">
    <h1>Vector Fields</h1>
</div>
<hr/>
<img align="left" src="https://user-images.githubusercontent.com/74130881/136701095-e8d9e525-e933-4e8a-86f7-61b70065d49b.png" width="360px" height="250px" /> Let's talk vectors today, specifically vector fields. As many of you may know, a vector has both a direction and a magnitude. You may already have used vectors in game development, programming and mathematics in general. Take a look at the image on the left to have a better understanding of a vector. Vector fields if not grids, but are a group of points in uniform order that are assigned different vectors. These points act as the 'tail' or the 'starting point' of the vector. These vectors are generalized and visualized as arrows with a direction and a magnitude.
<br/><br/>
Vector fields are used for several purposes, usually to have an understanding of the movement of fluid particles, gravitational forces, magnetic forces and atmospheric pressure. Today, We'll be looking at vector fields portraying fluid flow. 

# Static Vector Fields

Static vector fields are essentially vector fields whose vectors never change/are fixed. These fields are the representation of functions with same dimensions of their results and their parameters. Let's imagine, points in a uniform order are spread on a cartesian plane. These points mark tails (starting point) of vectors spread over the plane. To determine the direction and magnitude of these vectors, we'll write an arbritary function which takes in x and y (point). This function then produces an output which will be the direction of the vector. Let's take an easy to evaluate function to really get the hang of it. 
