<div align="center">
    <h1>Separating Axis Theorem</h1>
    <p>Detecting and Responding to collisions on a 2 dimensional plane</p>
</div>
<hr/>

In game development and computer graphics, one of the trickiest problem is simulating Collisions between two arbritary elements. Many find collision detection to be fairly easy (which is justified), but fail to simulate elastic collision responses. In this article, we'll look into a mathematical theorem which goes by the name of "Separating Axis Theorem". Some of the other articles over here, or even my custom physics engine uses this theorem to detect and respond to elastic collisions. 

The theorem states that two bodies don't collide, as long we are able to put a straight line between the two, that doesn't intersect either body. This should be easy to make the use of, but there is a downside to it. While it may be performant, it works only for Convex Shapes. If either of the body was a Concave shape, this theorem won't be too accurate with collision detection. The image below should clear it up for you.

![image](https://user-images.githubusercontent.com/74130881/134708625-09b4789d-98ae-4d71-92c6-06b2e66e43a0.png)

In Figure 1, both shapes are Convex polygons and do not collide. While, in Figure 2, one of the shapes is a Concave polygon. Both shapes appear to be free of any collisions but since the line intersects 1 of the shapes by this theorem, they are said to be colliding even though they are not. This shouldn't be too big of a problem unless its a large scale project. 

Now onto detecting collisions. We use something called a 'projection' of the two shapes. Let there be another line named the 'axis' which is perpendicular to the Separating line (line in between the two shapes). We can now project the shapes onto this perpendicular. IF the separating line intersect either of the projections, the shapes are said to be colliding. We do not need to worry about where we create the project (left or right), since the projection ultimately is no longer 2 dimensional, rather 1 dimensional. 

![image|250x250](https://user-images.githubusercontent.com/74130881/134711848-fdcda5cb-e42d-46ee-ba2e-1d7c9ea1e04f.png)


