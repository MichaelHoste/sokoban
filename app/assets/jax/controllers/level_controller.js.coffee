Jax.Controller.create "Level", ApplicationController,
  index: ->
    @movement = { up: 0, down: 0, left: 0, right: 0 }
    
    # load level and add to the scene
    @level = Level.find "actual"
    @world.addObject @level
    
    # load the components of the level and add on the scene
    for i in [0..@level.cols_number*@level.rows_number-1]
      if @level.objects[i] != null
        @world.addObject @level.objects[i]
              
    #@level.print()
      
  update: (timechange) ->    
    ;
    
    
  key_pressed: (event) ->
    has_moved = 0
    
    switch event.keyCode
      when KeyEvent.DOM_VK_UP    then has_moved = @level.move('u')
      when KeyEvent.DOM_VK_DOWN  then has_moved = @level.move('d')
      when KeyEvent.DOM_VK_LEFT  then has_moved = @level.move('l')
      when KeyEvent.DOM_VK_RIGHT then has_moved = @level.move('r')

    # if moved, refresh concerned level positions objects
    if has_moved != 0
      # take the new pusher position and its 4 direct neighbours
      pusher_m = @level.pusher_pos_m
      pusher_n = @level.pusher_pos_n
      positions =
        [
          [pusher_m,   pusher_n],
          [pusher_m+1, pusher_n],
          [pusher_m-1, pusher_n],
          [pusher_m,   pusher_n+1],
          [pusher_m,   pusher_n-1]
        ] 
   
      # visually refresh these 5 positions
      for position in positions
        index = @level.cols_number*position[0] + position[1]
        if @level.read_pos(position[0], position[1]) != 'E'
          @world.removeObject @level.objects[index]
          delete @level.objects[index]
          @level.display_position(position[0], position[1])
          @world.addObject @level.objects[index]