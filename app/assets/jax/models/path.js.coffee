Jax.getGlobal()['Path'] = Jax.Model.create

  # Constructor for a empty path
  after_initialize: ->
    @n_pushes   = 0
    @n_moves    = 0
    @moves      = []

  ###
    Add move in a direction
    @param direction direction where the pusher move
  ###
  add_move: (direction) ->
  	if @is_valid_direction(direction)
      @n_moves++
      @moves.push(direction.toLowerCase())

  ###
    Add push in a direction
    @param direction direction where pusher push a box
  ###
  add_push: (direction) ->
    if @is_valid_direction(direction)
      @n_moves++
      @n_pushes++
      @moves.push(direction.toUpperCase())
  
  ###
    Add displacement in a direction.
    push or move is automatically assigned following of the letter-case of direction
    @param direction direction where pusher push a box
  ###
  add_displacement: (direction) ->
    if @is_valid_direction(direction)
      if direction >= 'A' and direction <= 'Z'
        @n_pushes++
      else
        @n_moves++
      @moves.push(direction.toUpperCase())
  
  ###
    Get last move or push
  ###
  get_last_move: ->
    last_move = @moves[@moves.length - 1]
      
  ###
    Delete last move or push
  ###
  delete_last_move: ->
    if @n_moves > 0
      last_move = @moves.pop()
      if last_move >= 'A' and last_move <= 'Z'
        @n_pushes--
      @n_moves--
  
  ###
    Print path of this object
  ###
  print: ->
    line = ""
    for move in @moves
      line = line + move
    console.log(line)
  
  ###
    Is a direction valid (u,d,r,l,U,D,R,L)
    @param direction direction to test
    @return true if valid, false if not
  ###
  is_valid_direction: (direction) ->
    d = direction.toLowerCase()
    return (d == 'u' || d == 'd' || d == 'l' || d == 'r')
  