<div align="center">
     <h1>Optimizing 2D Curves</h1>
     <p>Reducing rendered objects without having an impact on the resolution</p>
</div>
<hr/>

# Overview

When rendering curves on the screen, we use up a lot objects to cover up the spaces between and to connect points (lying on the curve) together. Sometimes if not always, we tend to use more objects than actually necessary, this can hurt performance and take up a lot of memory. In this write-up, I cover a few methods that can help reduce memory usage when dealing with curves. 

The methods I'll be sharing are very beneficial for a number of situations. These include - drawing bezier curves, splines, optimizing drawing tools and much more. If you're dealing with such cases, stick around till the end.

Firstly, to answer an important question of "**Why?**", we'll go through a short example. 
