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

 1. Put link to my stuff at the bottom of the page (and also privacy and legal stuffs)
 2. Integrate application in fb canvas (https)
 3. Use "feed dialog", "request dialog" and "send dialog" when appropriate (request can only be used in canvas) (1)
 4. 99Design for main page
 5. Register to fb application
 6.  Create dashboard :
   * total users / total resolved levels / total boxes on goals
   * Top 10 friends
   * Top 10 all
   * Last levels from friends
   * Last levels from all
   * Invite more friends
   * Challenges (packs ?)
 7.  save the theme choice in the cookies : not sure to keep many themes. Don't worry about that
 8.  Implement challenges : invite 5 friend by challenge.
 9.  Implement advanced deadlock detection in coffeescript if fast enough (prototype algorithm of dead zone).
 10.  Send mails to users to tell about the last activities of their friends.
 
(1)
feed : http://developers.facebook.com/docs/reference/dialogs/feed/
request : http://developers.facebook.com/docs/reference/dialogs/requests/
send : http://developers.facebook.com/docs/reference/dialogs/send/

canvas : http://developers.facebook.com/docs/appsonfacebook/tutorial/