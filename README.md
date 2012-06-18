Sokoban
=======

WebGL implementation of Sokoban using jax (http://guides.jaxgl.com/).
Jax is a special gem for rails that enables nice WebGL implementation using a rails-style stucture

DEMO
----

Try it here : http://www.sokoban.be

![Image](https://github.com/MichaelHoste/sokoban/raw/master/sokoban.png)

TO DO
-----

 * keep active square and z deadlocks in memory
 * workflow when level is succeeded
 * Implement advanced deadlock detection in coffeescript if fast enough (prototype algorithm of dead zone)
 * try raphael to draw in 2D (for level thumbs)
 * try to adapt the url of the page to allow "back" (history)
 * Add indexes on level_user_links (scores) : pushes and moves
 * challenges : invite 1 friend by challenge