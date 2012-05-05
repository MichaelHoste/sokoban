Jax.getGlobal()['Level'] = Jax.Model.create
  
  after_initialize: ->
    @id = 0             # Level number (starting with 1)
    @name = ""          # Name of this level
    @packName = ""      # Name of pack that contains this level
    @grid = new Array() # Grid of the level
    @objects = new Array() # 
    @boxes_number = 0   # Number of boxes in this level
    @goals_number = 0   # Number of goals in this level
    @rows_number = 0    # Rows number
    @cols_number = 0    # Cols number
    @pusher_pos_m = 0   # M position of the pusher
    @pusher_pos_n = 0   # N position of the pusher
    @won = false        # is this level succeed ?
    
    @xml_load()
    
    for m in [0..@rows_number-1]
      for n in [0..@cols_number-1]
        type = @read_pos(m, n)
        if type == '#'
          object = Wall.find 'actual'
        else if type == '$' or type == '*'
          object = Box.find 'actual'
        else if type == 's'
          object = Ground.find 'actual'
        else if type == '.'
          object = Goal.find 'actual'
        else if type == '@' or type == '+'
          object = Pusher.find 'actual'
        else
          object = null
        
        if object != null
          start_col = -@cols_number/2.0
          start_row = @rows_number/2.0
          object.camera.setPosition [start_col + n, start_row - m, -20.0]
          @objects.push(object)


  ###
    Read the value of position (m,n).
    Position start in the upper-left corner of the grid with (0,0).
    @param m Row number.
    @param n Col number.
    @return Value of position (m,n) or 'E' if pos is out of grid.
  ###
  read_pos: (m, n) ->
    if m < @rows_number and n < @cols_number and m >= 0 and n >= 0
      return @grid[@cols_number*m + n]
    else
      return 'E'
      
  ###
    Write the value of letter in position (m,n).
    Position start in the upper-left corner of the grid with (0,0).
    @param m Row number.
    @param n Col number.
    @param letter value to assign at (m,n) in the grid
  ###
  write_pos: (m, n, letter) ->
    if m < @rows_number and n < @cols_number and m >= 0 and n >= 0
      @grid[@cols_number*m + n] = letter
    
  ###
    Initialize (find) starting position of pusher to store it in this object
  ### 
  initialize_pusher_position: ->
    find = false
    
    for cell, i in @grid
      if not find and cell in ['@', '+']
        @pusher_pos_m = i % @rows_number
        @pusher_pos_n = i / @rows_number
        find = true

  ###
    Transform empty spaces inside level in ground represented by 's' used
    to draw the level. Call to recursive function "makeFloorRec".
  ###
  make_ground: ->
    # Recursively set "inside ground" to 's' starting with pusher position
    @make_ground_rec(@pusher_pos_m, @pusher_pos_n)

    # Set back modified (by recusively method) symbols to regular symbols
    for cell, i in @grid
      if @grid[i] == 'p'
        @grid[i] = '.'
      else if @grid[i] == 'd' 
        @grid[i] = '$'
      else if @grid[i] == 'a'
        @grid[i] = '*'

  ###
    Recursive function used to transform inside spaces by ground ('s')
    started with initial position of sokoban.
    NEVER use this function directly. Use make_ground instead.
    @param m Rows number (start with sokoban position)
    @param n Cols number (start with sokoban position)
  ###
  make_ground_rec: (m, n) ->
    a = @read_pos(m, n)
  
    # Change of values to "ground" or "visited"
    if a == ' '
      @write_pos(m, n, 's')
    else if a == '.'
      @write_pos(m, n, 'p')
    else if a == '$'
      @write_pos(m, n, 'd')
    else if a == '*'
      @write_pos(m, n, 'a')
  
    # If non-visited cell, test neighbours cells
    if a != '#' && a != 's' && a != 'p' && a != 'd' && a != 'a'
      @make_ground_rec(m+1, n)
      @make_ground_rec(m-1, n)
      @make_ground_rec(m, n+1)
      @make_ground_rec(m, n-1)
        
  xml_load: ->
    @id = 1
    @rows_number = 11
    @cols_number = 19
    
    #for i in @rows_number * @cols_number
    #  @grid[i] = ' '
    
    @grid = [
      ' ', ' ', ' ', ' ', '#', '#', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
      ' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
      ' ', ' ', ' ', ' ', '#', '$', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
      ' ', ' ', '#', '#', '#', ' ', ' ', '$', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
      ' ', ' ', '#', ' ', ' ', '$', ' ', '$', ' ', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
      '#', '#', '#', ' ', '#', ' ', '#', '#', ' ', '#', ' ', ' ', ' ', '#', '#', '#', '#', '#', '#'
      '#', ' ', ' ', ' ', '#', ' ', '#', '#', ' ', '#', '#', '#', '#', '#', ' ', ' ', '.', '.', '#'
      '#', ' ', '$', ' ', ' ', '$', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '.', '.', '#'
      '#', '#', '#', '#', '#', ' ', '#', '#', '#', ' ', '#', '@', '#', '#', ' ', ' ', '.', '.', '#'
      ' ', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' ', ' ', '#', '#', '#', '#', '#', '#', '#', '#', '#'
      ' ', ' ', ' ', ' ', '#', '#', '#', '#', '#', '#', '#', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '
    ]

    # Find initial position of pusher
    @initialize_pusher_position()

    # Make ground inside the level
    #@make_ground()
    
    # Initialize number of boxes and goals
    for i in @rows_number * @cols_number
      pos = @grid[i]
      if(pos == '*' || pos == '$')
        @boxes_number = @boxes_number + 1
      if(pos == '+' || pos == '*' || pos == '.')
        @goals_number = @goals_number + 1

