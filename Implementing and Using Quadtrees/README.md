<div align="center"> 
    <h1>Quadtrees</h1>
    <p>Implementing and Using Quadtrees</p>
</div>
<hr/>

# Preface

Quadtrees are tree based data structures used prevalently in game development and computer graphics. These trees have at most 4 subdivisions/nodes. You might have heard about octrees before. Octrees are similar to quadtrees but unlike quadtrees, octrees are 3 dimensional and have 8 subdivisions that are cubes. These nodes, if visualized usually are squares, and their subdivisions are squares smaller than their parent node. Quadtrees are used in collision detection, game engines, image processing, mesh generation etc. In this article, we cover implementation, visualization of quadtrees as well collision detection with quadtrees. I also assume you know the basic architecture of how tree data structures work. If you aren't yet familiar with trees, consider checking them out before this article!

# Conceptual Understanding 

Quadtrees are usually mapped out in a 2 dimensional space with their subdivisions as quadrilateral regions. These regions subdivide into more regions, then those regions subdivide into more regions and this recursively goes on till a certain extent. We'll take a look both at graphs of quadtrees and regional representations.

They usually store data of points in a two-dimensional space. Each Node of a quadtree may or may not have subdivisions. To determine if a node has to subdivide into more nodes, we check the amount of points in a node/region. Each node has a 'capacity' that may or may not be constant for all nodes of a quadtree. This capacity determines the amount of points the node can have at once. If that amount exceeds the capacity, the node has to subdivide into 4 more nodes and this process continues. For instance, if a quadtree's nodes have a capacity of 2 points, and if 5 points are randomly spread across the 2 dimensional space, the quadtree may look like the following. The graph representation of the quadtree is also observable to the right. 

<img src="https://user-images.githubusercontent.com/74130881/138087580-5f0b342e-24ac-46cf-a236-8ba87ca64c98.png" alt="quadtree" width="300px" />&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/74130881/138088278-386d1baf-07fa-44c5-bfab-9f890c6f6c15.png" />

The positions of the points and the threshold for each node can varry thus giving us different sorts of results. But why bother about Quadtrees? Quadtrees make traversing through points 10 times more easier and efficient. Let's see how it makes our job easier and efficient.

Imagine a case of collision detection. There are entities spread across the screen. In order to detect if an entity collides with another, we usually loop through each entity, then loop through all entities and check if they collide. This is inefficient, why? Say you have 10 bodies. Each body checks collisions with all 10 bodies when traversing, this means, we end up performing 10^2, 100 checks in total. Let's step the number up from 10 to 10,000. How many checks do we perform this time? We perform 10000^2 or 100,000,000 checks. See how expensive this gets as you increase the amount of entities?

- To be completed.
