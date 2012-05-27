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

 * Draw the pack/index page
 * workflow when level is succeeded
 * Find why the textures are so pale (and why some color disappeared)
 * Implement basic deadlock detection in coffeescript (corners, 2 boxes etc.)
 * Implement advanced deadlock detection in coffeescript if fast enough (prototype algorithm of dead zone)
 * try raphael to draw in 2D (for fallback and level thumbs)