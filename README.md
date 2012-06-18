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

 1. Level thumbs using raphaeljs (special div with level string on it)
 2. Add indexes on level_user_links (scores) : pushes and moves
 3. Workflow when starting website
 4. Workflow when level is succeeded
 5. Keep active square and z deadlocks in memory
 6. Implement challenges : invite 5 friend by challenge
 7. Try to adapt the url of the page to allow "back" (history)
 8. Implement advanced deadlock detection in coffeescript if fast enough (prototype algorithm of dead zone)