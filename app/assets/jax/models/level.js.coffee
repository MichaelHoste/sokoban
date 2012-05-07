Jax.getGlobal()['Level'] = Jax.Model.create
  
  after_initialize: ->
    @id = 0             # Level number (starting with 1)
    @name = ""          # Name of this level
    @packName = ""      # Name of pack that contains this level
    @grid = []          # Grid of the level
    @objects = []       # list of objects to be displayed
    @boxes_number = 0   # Number of boxes in this level
    @goals_number = 0   # Number of goals in this level
    @rows_number = 0    # Rows number
    @cols_number = 0    # Cols number
    @pusher_pos_m = 0   # M position of the pusher
    @pusher_pos_n = 0   # N position of the pusher
    @won = false        # is this level succeed ?
    
    # load level
    pack_name = $("#packs").find(".is-selected").text()
    level_name = $("#levels").find(".is-selected").text()
    @xml_load(pack_name, level_name)
    
    # display level
    @display_level()

  display_level: ->
    for m in [0..@rows_number-1]
      for n in [0..@cols_number-1]
        @display_position(m, n)
        
  display_position: (m, n) ->
    type = @read_pos(m, n)
    
    # create object
    if type != ' ' and not @objects[@cols_number*m + n]
      object = Ground.find 'actual'
      @objects[@cols_number*m + n] = object
      
      start_col = -@cols_number/2.0 + 0.5
      start_row = @rows_number/2.0 - 0.5
      
      d_height = @rows_number / (2*0.414213563) * 1.1 # 0.41... = tan(22.5°), *0.9 is to create a border
      d_width = @cols_number / (2*0.414213563/14*18) # 0.41... = tan(22.5°), 14*18 is the ration height/width
      d = d_height if d_height > d_width
      d = d_width  if d_width  > d_height
            
      object.camera.setPosition [start_col + n, start_row - m, -d]
      
    # refresh material
    if type == '#'
      object.mesh.material = "wall"
    else if type == '$'
      object.mesh.material = "box"
    else if type == '*'
      object.mesh.material = "boxgoal"
    else if type == 's'
      object.mesh.material = "ground"
    else if type == '.'
      object.mesh.material = "goal"
    else if type == '@'
      object.mesh.material = "pusher"
    else if type == '+'
      object.mesh.material = "pushergoal"
      
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
    Look if pusher can move in a given direction
    @param direction 'u', 'd', 'l', 'r' in lowercase and uppercase
    @return true if pusher can move in this direction, false if not.
  ###
  pusher_can_move: (direction) ->
    mouv1 = ' '
    mouv2 = ' '
    m = @pusher_pos_m
    n = @pusher_pos_n

    # Following of the direction, test 2 cells
    if direction == 'u'
      mouv1 = @read_pos(m-1, n)
      mouv2 = @read_pos(m-2, n)
    else if direction == 'd'
      mouv1 = @read_pos(m+1, n)
      mouv2 = @read_pos(m+2, n)
    else if direction == 'l'
      mouv1 = @read_pos(m, n-1)
      mouv2 = @read_pos(m, n-2)
    else if direction == 'r'
      mouv1 = @read_pos(m, n+1)
      mouv2 = @read_pos(m, n+2)

    # If (there is a wall) OR (two boxes or one box and a wall)
    if mouv1 == '#' or ((mouv1 == '*' || mouv1 == '$') and (mouv2 == '*' || mouv2 == '$' || mouv2 == '#'))
      return false
    else
      return true

  ###
    Move the pusher in a given direction and save it in the actualPath
    @param direction Direction where to move the pusher (u,d,l,r,U,D,L,R)
    @return 0 if no move.
            1 if normal move.
            2 if box move.
  ###
  move: (direction) ->
    action = 1
    m = @pusher_pos_m
    n = @pusher_pos_n

    # accept upper and lower dir
    direction = direction.toLowerCase()

    # Following of the direction, test 2 cells
    if direction == 'u' && @pusher_can_move('u')
      m_1 = m-1
      m_2 = m-2
      n_1 = n_2 = n
      @pusher_pos_m = @pusher_pos_m - 1
    else if direction == 'd' && @pusher_can_move('d')
      m_1 = m+1
      m_2 = m+2
      n_1 = n_2 = n
      @pusher_pos_m = @pusher_pos_m + 1
    else if direction == 'l' && @pusher_can_move('l')
      n_1 = n-1
      n_2 = n-2
      m_1 = m_2 = m
      @pusher_pos_n = @pusher_pos_n - 1
    else if direction == 'r' && @pusher_can_move('r')
      n_1 = n+1
      n_2 = n+2
      m_1 = m_2 = m
      @pusher_pos_n = @pusher_pos_n + 1
    else
      action = 0
      state = 0

    # Move accepted
    if action == 1
      state = 1

      # Test on cell (m,n)
      if @read_pos(m, n) == '+'
        @write_pos(m, n, '.')
      else
        @write_pos(m, n, 's')

      # Test on cell (m_2,n_2)
      if @read_pos(m_1, n_1) == '$' or @read_pos(m_1, n_1) == '*'
        if @read_pos(m_2, n_2) == '.'
          @write_pos(m_2, n_2, '*')
        else
          @write_pos(m_2, n_2, '$')

        # Save push
        #actualPath->addPush(dir)
        state = 2

      # Test on cell (m_1, n_1)
      if @read_pos(m_1, n_1) == '.' || @read_pos(m_1, n_1)=='*'
        @write_pos(m_1, n_1, '+')
      else
        @write_pos(m_1, n_1, '@')

      # Save move
      #if state != 2
      # actualPath->addMove(dir)

    return state
  
  ###
    Return true if all boxes are in their goals.
    @return true if all boxes are in their goals, false if not
  ###
  isWon: ->
    for i in [0..@rowsNumber*@colsNumber-1]
      if grid[i] == '$'
        return false;
    return true;
    
  ###
    Initialize (find) starting position of pusher to store it in this object
  ### 
  initialize_pusher_position: ->
    find = false
    
    for cell, i in @grid
      if not find and cell in ['@', '+']
        @pusher_pos_n = i % @cols_number
        @pusher_pos_m = Math.floor(i / @cols_number)
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
      if cell == 'p'
        @grid[i] = '.'
      else if cell == 'd' 
        @grid[i] = '$'
      else if cell == 'a'
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
      
  print: ->
    for m in [0..@rows_number-1]
      line = ""
      for n in [0..@cols_number-1]
        line = line + @read_pos(m, n)
      console.log(line + '\n')
  
  ###
    Load a specific level in a XML pack
    @pack name of the file (without .slc)
    @id id of the level (string) 
  ###
  xml_load: (pack, id) ->
    @id = id
     
    $.ajax({
      type:     "GET",
      url:      "./levels/" + pack + ".slc",
      dataType: "xml",
      success:  @xml_parser
      async:    false
      context:  @
    })
    
  xml_parser: (xml) ->    
    xml_level = $(xml).find('Level[Id="' + @id + '"]')
    
    @rows_number = $(xml_level).attr("Height")
    @cols_number = $(xml_level).attr("Width")
    
    for i in [0..@rows_number*@cols_number-1]
      @grid[i] = ' '
      
    lines = $(xml_level).find("L")
    
    for line, i in lines
      text = $(line).text()
      for j in [0..text.length-1]
        @grid[@cols_number*i + j] = text.charAt(j)
        
    #@print()

    # Find initial position of pusher
    @initialize_pusher_position()

    # Make ground inside the level
    @make_ground()
    
    # Initialize number of boxes and goals
    for i in @rows_number * @cols_number
      pos = @grid[i]
      if(pos == '*' || pos == '$')
        @boxes_number = @boxes_number + 1
      if(pos == '+' || pos == '*' || pos == '.')
        @goals_number = @goals_number + 1
