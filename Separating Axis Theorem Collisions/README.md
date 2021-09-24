<div align="center">
    <h1>Separating Axis Theorem</h1>
    <p>Detecting and Responding to collisions on a 2 dimensional plane</p>
</div>
<hr/>

In game development and computer graphics, one of the trickiest problem is simulating Collisions between two arbritary elements. Many find collision detection to be fairly easy (which is justified), but fail to simulate elastic collision responses. In this article, we'll look into a mathematical theorem which goes by the name of "Separating Axis Theorem". Some of the other articles over here, or even my custom physics engine uses this theorem to detect and respond to elastic collisions. 

The theorem states that two bodies don't collide, as long we are able to put a straight line between the two, that doesn't intersect either body. This should be easy to make the use of, but there is a downside to it. While it may be performant, it works only for Convex Shapes. If either of the body was a Concave shape, this theorem won't be too accurate with collision detection. The image below should clear it up for you.

![image](https://user-images.githubusercontent.com/74130881/134708625-09b4789d-98ae-4d71-92c6-06b2e66e43a0.png)

In Figure 1, both shapes are Convex polygons and do not collide. While, in Figure 2, one of the shapes is a Concave polygon. Both shapes appear to be free of any collisions but since the line intersects 1 of the shapes by this theorem, they are said to be colliding even though they are not. This shouldn't be too big of a problem unless its a large scale project.
