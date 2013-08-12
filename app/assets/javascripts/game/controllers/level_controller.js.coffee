class window.LevelController

  constructor: ->
    # get the names of the pack and level
    pack_name = $('#packs').attr('data-pack-slug')
    level_name = $('#levels').find('.is-selected').attr('data-level-slug')

    # create level
    @level = new Level()
    @level.create(pack_name, level_name)

    # Initalize path
    @path = new PathCore()

    # initialize moves/pushes counter
    @update_counters()

    # Initialize deadlocks
    @deadlock = new DeadlockCore(@level.level_core)

    # the game is not freezed (keyboard arrows can be used)
    @freezed_game = false

    # Initialize keyboard
    $(document).on('keydown', (event) =>
      @key_pressed(event)
    )

  key_pressed: (event) ->
    has_moved = 0
    has_deleted = 0

    # freezed game, no move allowed
    if @freezed_game
      return false

    move_letter = ' '
    switch(event.which || event.keyCode)
      when 38  then move_letter = 'u'  # up
      when 40  then move_letter = 'd'  # down
      when 37  then move_letter = 'l'  # left
      when 39  then move_letter = 'r'  # right
      when 100 then has_deleted = @level.delete_last_move(@path) # d
      when 68  then has_deleted = @level.delete_last_move(@path) # D

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
        @freezed_game = true
        @star_level()

        # load selected level
        level_id   = parseInt($('#levels').find('.is-selected').attr('data-level-id'))

        $.post('/scores',
          level_id: level_id
          path:     @path.get_compressed_string_path()
          authenticity_token: window.authenticity_token()
        )
        .success((data, status, xhr) =>
          window.update_banner()
          window.update_packs_select()

          if window.is_logged()
            window.colorbox_next_level(level_id, data.score_id)
          else
            window.colorbox_facebook()
        )

  highlight_deadlocks: (has_moved, has_deleted) ->
    if has_moved == 2 or has_deleted != 0
      box_position = @position_of_last_pushed_box()
      deadlocked_positions = @deadlock.deadlocked_boxes(@level)
      deadlocked_positions = @deadlock.deadlocked_last_push(@level, box_position, deadlocked_positions)
      @level.highlight(deadlocked_positions)

      # "there is a deadlock" div
      if deadlocked_positions.length != 0
        console.log(@level)
        console.log(deadlocked_positions)
        $('#deadlock').fadeIn(1000)
      else
        $('#deadlock').fadeOut(500)

  # star selected level
  star_level: ->
    button = $('#levels').find('.is-selected .level-index').prev()
    if not button.hasClass('s-icon-star')
      button.removeClass('s-icon-star-empty')
      button.addClass('s-icon-star')

      global_success = parseInt($("#user-infos").attr('data-global-success'))
      $("#user-infos").attr('data-global-success', global_success+1)

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
