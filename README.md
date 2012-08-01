Sokoban
=======

WebGL implementation of Sokoban using jax (http://guides.jaxgl.com/).
Jax is a special gem for rails that enables nice WebGL implementation using a rails-style stucture

DEMO
----

Try it here : http://www.sokoban.be

![Image](https://github.com/MichaelHoste/sokoban/raw/master/misc/sokoban.png)

TO DO
-----

 1.  Create dashboard :
   * total users / total resolved levels / total boxes on goals
   * Top 10 friends
   * Top 10 all
   * Last levels from friends
   * Last levels from all
   * Invite more friends
   * Challenges (packs ?)
 1.a sort user thumbs (in a pack, there is an error, they are sorted by absolute number of win)
 2.  paginate level scores
 3a. make the banner images on top of the "fork me on github".
 3b. save the theme choice in the cookies : not sure to keep many themes. Don't worry about that
 4.  Implement challenges : invite 5 friend by challenge.
 5.  Implement advanced deadlock detection in coffeescript if fast enough (prototype algorithm of dead zone).
 6.  Send mails to users to tell about the last activities of their friends.