Jax.Controller.create "Level", ApplicationController,
  index: ->
    # unload old level if exists
    if @level
      @level.unload(@world)
      delete @level
    
    # load selected level and add it to the world
    @level = Level.find "actual"
    @world.addObject @level
        
    # Initalize path
    @path = new PathCore()
            
    # load the components of the level and add them on the world
    for i in [0..@level.cols_number()*@level.rows_number()-1]
      if @level.objects[i]
        @world.addObject @level.objects[i]
      
  update: (timechange) ->    
    ;
    
  key_pressed: (event) ->
    has_moved = 0
    has_deleted = 0
    
    move_letter = ' '
    switch event.keyCode
      when KeyEvent.DOM_VK_UP    then move_letter = 'u'
      when KeyEvent.DOM_VK_DOWN  then move_letter = 'd'
      when KeyEvent.DOM_VK_LEFT  then move_letter = 'l'
      when KeyEvent.DOM_VK_RIGHT then move_letter = 'r'
      when KeyEvent.DOM_VK_D     then has_deleted = @level.delete_last_move(@path)

    has_moved = @level.move(move_letter)

    # if moved, refresh concerned level positions objects
    if has_moved != 0
      # save move
      @path.add_move(move_letter) if has_moved == 1
      @path.add_push(move_letter) if has_moved == 2

    if has_moved != 0 or has_deleted != 0
      @level.refresh(has_deleted)
