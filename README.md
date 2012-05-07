Sokoban
=======

WebGL implementation of Sokoban using jax (http://guides.jaxgl.com/).
Jax is a special gem for rails that enables nice WebGL implementation using a rails-style stucture

DEMO
----

Try it here : http://opengl-fr.be/sokoban/

![Image](https://github.com/MichaelHoste/sokoban/raw/master/sokoban.png)

TO DO
-----

 * Override the level render method : include the squares render inside. Move it out of the levelcontroller so it will be easier to translate and rotate the entire level. It will also be easier to manage the memory of the entire level at one point.
 * Find why the textures are so pale (and why some color disappeared)
 * Design the page : login, scores (wall of fame ?), level and pack infos and so on.
 * Save paths