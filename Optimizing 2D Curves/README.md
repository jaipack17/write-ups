<div align="center">
     <h1>Optimizing 2D Curves</h1>
</div>
<hr/>

# Overview

When rendering curves on the screen, we use up a lot objects to cover up the spaces between and to connect points (lying on the curve) together. Sometimes if not always, we tend to use more objects than actually necessary, this can hurt performance and take up a lot of memory. In this write-up, I cover a few methods that can help reduce memory usage when dealing with curves. 

The techniques I'll be sharing are very beneficial for a number of situations. These include - drawing bezier curves, splines, optimizing drawing tools and much more. If you're dealing with such cases, stick around till the end.

Firstly, to answer an important question of "**Why?**". Let's say you create a drawing board/tool, audio visualizer or any other piece of work that requires you to render one or more curves on the screen. Maybe even update curves each frame (At 60 fps, updating them 60 times a second) or updating them every once in a while. With 'updating' I refer to the procedure of recalculating the curve and rendering it on the screen. If the curves are huge, or if there are too many curves, they are going to take up a lot of resources, especially memory. Updating them multiple times would also be a tedious task since there exist too many points on the curve to traverse through. Reducing the number of points when calculating a curve or after calculating a curve will make it easier and faster to traverse through but will also save memory. Hence the reason to why it is important to sneak in optimizations whereever possible and logical.
