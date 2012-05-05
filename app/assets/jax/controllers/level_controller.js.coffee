Jax.Controller.create "Level", ApplicationController,
  index: ->
    #@object_list = new Array()
    @movement = { up: 0, down: 0, left: 0, right: 0 }
    @level = Level.find "actual"
      
    @world.addObject @level
    for object in @level.objects
      @world.addObject object
      
    @level.print()
      
  update: (timechange) ->
    # delete object list
    #for object in @object_list
    #  @world.removeObject(object)
    
    if @movement.up != 0
      @level.move('u')
      @level.print()
      
    #reinitialize
    #@level.display_level()
    #for object in @level.objects
    #  @object_list.push(@world.addObject object)

  key_pressed: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_UP    then @movement.up    =  1
      when KeyEvent.DOM_VK_DOWN  then @movement.down  =  1
      when KeyEvent.DOM_VK_LEFT  then @movement.left  =  1
      when KeyEvent.DOM_VK_RIGHT then @movement.right =  1

  key_released: (event) ->
    switch event.keyCode
      when KeyEvent.DOM_VK_UP    then @movement.up    =  0
      when KeyEvent.DOM_VK_DOWN  then @movement.down  =  0
      when KeyEvent.DOM_VK_LEFT  then @movement.left  =  0
      when KeyEvent.DOM_VK_RIGHT then @movement.right =  0
    