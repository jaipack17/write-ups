<div align="center">
     <h1>Tetrahedralization</h1>
     <p>Dividing arbitrary polyhedrons into tetrahedrons using code</p>
</div>

<hr/>

## Overview
You might have come accross the idea of dividing polygons into sets of triangles, which is more commonly known as [triangulation](https://en.wikipedia.org/wiki/Polygon_triangulation#:~:text=In%20computational%20geometry%2C%20polygon%20triangulation,of%20planar%20straight%2Dline%20graphs.). The word 'tetrahedralization' can be overwhelming at first glance, so in simpler terms tetrahedralization is triangulation but in 3 dimensions. Tetrahedralization refers to the decomposition/division of a polyhedron into sets of tetrahedrons.

### Terminology
*Polyhedron* - 3D (R³) equivalent of a polygon. Its faces are polygons which together join with each other to form a 3D solid figure called a polyhedron.<br/>
*Tetrahedron* - A tetrahedron is a polyhedron which comprises of 4 conjoined triangular faces. A tetrahedron is also known as a triangular pyramid.<br/>

If you are looking for ways to divide arbitrary 3D shapes into tetrahedrons, then continue reading! The methods I'll be sharing have great application in a variety of cases. All algorithms below have been implemented in [Luau](https://luau-lang.org/).

<hr/>

