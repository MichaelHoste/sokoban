###
  Class usefull to represent a way to move in a level.
  
  Pushes are represented by upper case and moves by lower case
  It could be written in COMPRESSED mode, but in this class, it's
  UNCOMPRESSED for rapidity and flexibility.
  
  In compressed mode, when many moves in one direction, letters are prefixed
  by numbers.
  
  example uncompressed mode : rrrllUUUUUruLLLdlluRRRRdr
  example compressed mode : 3r2l5Uru3Ld2lu4Rdr
###

class window.PathCore

  # Constructor for a empty path
  constructor: ->
    @n_pushes   = 0
    @n_moves    = 0
    @moves      = []

  ###
    Constructor from an uncompressed path
    @param uncompressed_path (string)
  ###
  create_from_uncompressed: (uncompressed_path) ->
    @n_pushes   = 0
    @n_moves    = 0
    @moves      = []
  
    for i in [0..uncompressed_path.length-1]
      @add_displacement(uncompressed_path[i])

  ###
    Constructor from a compressed path
    @param compressed_path (string)
  ###
  create_from_compressed: (compressed_path) ->
    @n_pushes    = 0
    @n_moves     = 0
    @moves       = []
    cmpr_moves   = []
    uncmpr_moves = []
    
    for i in [0..compressed_path.length-1]
      cmpr_moves.push(compressed_path[i])
    uncmpr_moves = @uncompress_path(cmpr_moves)
    
    for move in uncmpr_moves
      @add_displacement(move)

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
      @moves.push(direction)
  
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
    print path
  ###
  print: ->
    @print_uncompressed()
  
  ###
    Print uncompressed path of this object
  ###
  print_uncompressed: ->    
    line = ""
    for move in @moves
      line = line + move
    console.log(line)
    
  ###
    Print compressed path of this object
  ###
  print_compressed: ->
    compressed_moves = @compress_path(@moves)
    
    line = ""
    for move in compressed_moves
      line = line + move
    console.log(line)
    
  ###
    Get the string path
    @return uncompressed string path
  ###
  get_uncompressed_string_path: ->
    line = ""
    for move in @moves
      line = line + move
    return line

  ###
    Get the string path
    @return compressed string path
  ###
  get_compressed_string_path: ->
    compressed_moves = @compress_path(@moves)
    
    line = ""
    for move in compressed_moves
      line = line + move
    return line
  
  ###
    Is a direction valid (u,d,r,l,U,D,R,L)
    @param direction direction to test
    @return true if valid, false if not
  ###
  is_valid_direction: (direction) ->
    d = direction.toLowerCase()
    return (d == 'u' || d == 'd' || d == 'l' || d == 'r')
  
  ###
    Compress a path (see description of class)
    @param path uncompressed path
    @return compressed path (array)
  ###
  compress_path: (uncompressed_path) ->
    cpt_c = 1
    compressed_path = []
  
    # We loop on each cell of the uncompressed path
    length = uncompressed_path.length
    i = 0
    while i < length
      j = 0
      tabi = uncompressed_path[i]
      
      # while it's the same displacement and we're not in the end
      while tabi == uncompressed_path[i] && i < length
        # (Identical moves)++
        j = j + 1
        i = i + 1

      # If there are many moves in one direction 
      if j >= 2
        for k in [0..j.toString().length-1]
          compressed_path.push(j.toString().substr(k, 1))
  
      # In every case, add direction and '\0' next to it
      compressed_path.push(tabi)
  
    return compressed_path
  
  ###
    Uncompress a path (see description of Path class)
    @param path compressed path
    @return uncompressed path (array)
  ###
  uncompress_path: (compressed_path) ->
    i = 0
    uncompressed_path = []
    
    # While we're not in the end of compressed path
    while i < compressed_path.length
      cell = compressed_path[i]
      nbr_buffer = []
      
      # if not decimal, only 1 move/push
      if cell < '0' or cell > '9' 
        nbr_buffer.push('1')
    
      # if decimal, we put it in buffer to create a number like ['1', '2'] for 12
      while cell >= '0' and cell <= '9' 
        nbr_buffer.push(cell)
        i = i + 1
        cell = compressed_path[i]
    
      # we transform the array on string...
      nbr_string = ""
      for letter in nbr_buffer
        nbr_string = nbr_string + "#{letter}"

      # ... and then convert the string on integer
      nbr = parseInt(nbr_string)
    
      # write nbr times the move/push
      for j in [0..nbr-1]
        uncompressed_path.push(compressed_path[i])
    
      i = i + 1
    
    return uncompressed_path
