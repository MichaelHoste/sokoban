Jax.Controller.create "Level", ApplicationController,
  index: ->
    # watch if it's a redirect (the level already exist. ex : 3D <-> 2D switch)
    if @level
      if @display_switch() == '3D'
        @level.switch_to_3d()
      else
        @level.switch_to_2d()
    # load selected level and add it to the world
    else
      # get the names of the pack and level
      pack_name = $('#packs > li').text()
      level_name = $('#levels').find('.is-selected .level-index').attr('title')
      
      # create level in 2D or 3D
      @level = Level.find "actual"
      if @display_switch() == '3D'
        @level.create_3d(pack_name, level_name)
      else
        @level.create_2d(pack_name, level_name)
      
      # add level to the world
      @world.addObject @level
        
      # Initalize path
      @path = new PathCore()
      
      # initialize moves/pushes counter
      @update_counters()
    
    # Initialize deadlocks
    @deadlock = new DeadlockCore(@level.level_core)
    
    # the game is not freezed (keyboard arrows can be used)
    @freezed_game = false
      
  update: (timechange) ->
    ;
    
  key_pressed: (event) ->
    has_moved = 0
    has_deleted = 0
    
    # freezed game, no move allowed
    if @freezed_game
      return false
    
    move_letter = ' '
    switch event.keyCode
      when KeyEvent.DOM_VK_UP    then move_letter = 'u'
      when KeyEvent.DOM_VK_DOWN  then move_letter = 'd'
      when KeyEvent.DOM_VK_LEFT  then move_letter = 'l'
      when KeyEvent.DOM_VK_RIGHT then move_letter = 'r'
      when KeyEvent.DOM_VK_D     then has_deleted = @level.delete_last_move(@path)

    # move
    has_moved = @level.move(move_letter)

    # save move
    @save_move(has_moved, move_letter)
    
    # if moved, refresh concerned level positions objects
    if has_moved != 0 or has_deleted != 0
      @level.display_level()
      @level.highlight(@deadlock.deadlock_positions)
      #@level.highlight(@deadlock.deadlocked_boxes(@level))
      
    # update pushes and moves counter
    @update_counters()
    
    # check if level is won, and save the score if it is
    @save_solution_if_any(has_moved)
        
  save_move: (has_moved, move_letter) ->
    if has_moved != 0
      @path.add_move(move_letter) if has_moved == 1
      @path.add_push(move_letter) if has_moved == 2
      
  save_solution_if_any: (has_moved) ->
    if has_moved != 0
      if @level.is_won()
        # load selected level
        pack_name = $('#packs > li').text()
        level_name = $('#levels').find('.is-selected .level-index').attr('title')
        token_tag = window.authenticity_token()
        
        $.post('/scores', 
          pack_id:  pack_name
          level_id: level_name
          path:     @path.get_compressed_string_path()
          authenticity_token: token_tag
        )
        .success((data, status, xhr) =>
          if data.result == "ok"
            if window.is_logged()
              window.colorbox_next_level()
            else
              window.colorbox_facebook()
        )
        
        @freezed_game = true        
        @star_level()
        alert("niveau réussi !")
        
  # star selected level
  star_level: ->
    button = $('#levels').find('.is-selected .level-index').prev()
    button.removeClass('icon-star-empty')
    button.addClass('icon-star')
    
  # "3D" if 3D switch is on, "2D" if 2D switch is on
  display_switch: ->
    $('#menus .switch.is-selected').text()
    
  update_counters: ->
    $('#current-score .score-pushes').text(@path.n_pushes)
    $('#current-score .score-moves').text(@path.n_moves)