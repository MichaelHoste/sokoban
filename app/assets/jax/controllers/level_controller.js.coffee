Jax.Controller.create "Level", ApplicationController,
  index: ->
    # get the names of the pack and level
    pack_name = $('#packs').attr('data-pack-name')
    level_name = $('#levels').find('.is-selected').attr('data-level-name')

    # create level in 2D or 3D
    @level = Level.find "actual"
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
    if window.old_theme != window.theme
      window.old_theme = window.theme
      @level.display_level()

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
      @highlight_deadlocks(has_moved, has_deleted)

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
        pack_name = $('#packs').attr('data-pack-name')
        level_name = $('#levels').find('.is-selected').attr('data-level-name')
        token_tag = window.authenticity_token()

        $.post('/scores',
          pack_id:  pack_name
          level_id: level_name
          path:     @path.get_compressed_string_path()
          authenticity_token: token_tag
        )
        .success((data, status, xhr) =>
          window.update_banner()

          if window.is_logged()
            window.colorbox_next_level(pack_name, level_name, data.score_id)
          else
            window.colorbox_facebook()
        )

        @freezed_game = true
        @star_level()

  highlight_deadlocks: (has_moved, has_deleted) ->
    if has_moved == 2 or has_deleted != 0
      box_position = @position_of_last_pushed_box()
      deadlocked_positions = @deadlock.deadlocked_boxes(@level)
      deadlocked_positions = @deadlock.deadlocked_last_push(@level, box_position, deadlocked_positions)
      @level.highlight(deadlocked_positions)

      # "there is a deadlock" div
      if deadlocked_positions.length != 0
        $('#deadlock').fadeIn(1000)
      else
        $('#deadlock').fadeOut(500)

  # star selected level
  star_level: ->
    button = $('#levels').find('.is-selected .level-index').prev()
    button.removeClass('s-icon-star-empty')
    button.addClass('s-icon-star')

  update_counters: ->
    $('#current-score .score-pushes').text(@path.n_pushes)
    $('#current-score .score-moves').text(@path.n_moves)

  ###
    Return the position of the last pushed box after push or deletion
    @return position {m, n} of the last pushed box
  ###
  position_of_last_pushed_box: ->
    pusher_pos = @level.pusher_pos()
    letter = @path.get_last_move()
    m = pusher_pos.m
    n = pusher_pos.n

    if letter == 'U'
      return {m: m-1, n: n}
    else if letter == 'D'
      return {m: m+1, n: n}
    else if letter == 'L'
      return {m: m, n: n-1}
    else if letter == 'R'
      return {m: m, n: n+1}
    else
      return false
