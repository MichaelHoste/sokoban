Sokoban
=======

WebGL/RaphaelJS implementation of Sokoban using jax (http://guides.jaxgl.com/).

Jax is a special gem for rails that enables nice WebGL implementation using a rails-style stucture. In our case, WebGL is disabled by default to increase the game compatibility (JaxGL is only used for its javascript MVC structure).

DEMO
----

Try it here : http://www.sokoban.be

![Image](https://github.com/MichaelHoste/sokoban/raw/master/_html/sokoban.png)

TO DO
-----

 0. Select an open-source license (GPL ? MIT ?). Find a way to exclude the packs/levels from it.
 1. Use "feed dialog" (success ?) when appropriate (1)
 3. Create fan page
 5.  Create dashboard :
   * total users / total resolved levels / total boxes on goals
   * Top 10 friends
   * Top 10 all
   * Last levels from friends
   * Last levels from all
   * Challenges (packs ?)
 7.  Implement challenges with awards : invite 5 friend by challenge.
 8.  Implement advanced deadlock detection in coffeescript if fast enough (prototype algorithm of dead zone).
 9.  Send mails to users to tell about the last activities of their friends.

(1)

feed : http://developers.facebook.com/docs/reference/dialogs/feed/

request : http://developers.facebook.com/docs/reference/dialogs/requests/

send : http://developers.facebook.com/docs/reference/dialogs/send/

canvas : http://developers.facebook.com/docs/appsonfacebook/tutorial/
