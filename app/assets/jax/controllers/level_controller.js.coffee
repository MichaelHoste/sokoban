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
      @level.refresh(has_deleted)
    
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
            alert("niveau réussi !")
            @star_level()
            @freezed_game = true
            if window.is_logged()
              window.colorbox_next_level()
            else
              window.colorbox_facebook()
        )
        
  # star selected level
  star_level: ->
    button = $('#levels').find('.is-selected .level-index').prev()
    button.removeClass('icon-star-empty')
    button.addClass('icon-star')
    
    