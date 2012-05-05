movement = 
  forward: 0
  backward: 0
  left: 0
  right: 0

Jax.Controller.create "Level", ApplicationController,
  index: ->
    @level = Level.find "actual"
    @world.addObject level
    for object in level.objects
      @world.addObject object

  key_pressed: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_W then movement.forward  =  1
      when KeyEvent.DOM_VK_S then movement.backward = -1
      when KeyEvent.DOM_VK_A then movement.left     = -1
      when KeyEvent.DOM_VK_D then movement.right    =  1

  key_released: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_W then movement.forward  = 0
      when KeyEvent.DOM_VK_S then movement.backward = 0
      when KeyEvent.DOM_VK_A then movement.left     = 0
      when KeyEvent.DOM_VK_D then movement.right    = 0
      
  update: (timechange) ->
    speed = 1.5 * timechange

    @level.
    @player.camera.move (movement.forward + movement.backward) * speed
    @player.camera.strafe (movement.left + movement.right) * speed