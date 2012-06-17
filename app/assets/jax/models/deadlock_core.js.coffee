###
  Class to deal with deadlocks (situations where the level cannot be resolved)
###

class window.DeadlockCore

  ###
    Constructor
    @param level we want to test for deadlocks
  ###
  constructor: (level) ->
    # array of positions where a box trigger a deadlock situation
    @deadlock_positions = @create_deadlock_positions(level)

  ###
    Create list of deadlocked positions of the level (corners, lines etc.)
    A deadlocked position is a position that makes impossible to solve the level when a box is on it
    @param level we want to test for deadlocks
    @return array of deadlocked positions for the level (corners, lines etc.)
  ###
  create_deadlock_positions: (level) ->
    deadlock_positions = @create_corner_deadlock_positions(level)
    deadlock_positions = @create_line_deadlock_positions(level, deadlock_positions)
    return deadlock_positions
      
  ###
    This function add corner deadlocks to deadlock zone. This happened when
    a box is in a corner made by walls
    @param level we want to test for corner deadlocks
    @return array of corner deadlock positions
  ###
  create_corner_deadlock_positions: (level) ->
    deadlock_positions = []
    
    for m in [0..level.rows_number-1]
      for n in [0..level.cols_number-1]
        pos = level.read_pos(m, n)
        # If not outside, not wall, not goal and in a corner, add the position in the deadlock array
        if pos != ' ' && pos != '#' && pos != '.' && pos != '*' && pos != '+'
          if @is_in_corner(level, m, n)
            deadlock_positions.push( {m: m, n: n} )
    
    return deadlock_positions
         
  ###
    This method add line deadlocks to deadlock zone. This happened when
    there is a box next a wall and no way to remove it (escape move)
    You must apply this function AFTER having use the method
    create_corner_deadlock_positions because we need corner positions.
    @param level we want to test for line deadlocks
    @param corner_deadlock_positions list of corner deadlock positions
    @return array of corner and line deadlock positions
  ###
  create_line_deadlock_positions: (level, corner_deadlock_positions) ->    
    line_deadlock_positions = []
    for corner_pos in corner_deadlock_positions
      escape = { up: false, down: false, left: false, right: false, goal: false }  
      
      ###
      # Test horizontal lines
      ###
      
      # while cell is not wall
      cell_pos = { m:corner_pos.m, n:corner_pos.n }
      cell = level.read_pos(cell_pos.m, cell_pos.n)
      while cell != '#'
        # If the cell on top of the actual cell is not wall
        if level.read_pos(cell_pos.m - 1, cell_pos.n) != '#'
          escape.up = true
        # If the cell on the bottom of the actual cell is not wall
        if level.read_pos(cell_pos.m + 1, cell_pos.n) != '#'
          escape.down = true
        # If cell is goal
        if cell == '.' or cell == '*' or cell == '+'
          escape.goal = true

        cell_pos.n = cell_pos.n + 1
        cell = level.read_pos(cell_pos.m, cell_pos.n)

      # mark horizontal line if up or down is full of walls and has no goal
      if (escape.up == false or escape.down == false) and escape.goal == false
        cell_pos = { m:corner_pos.m, n:corner_pos.n }
        while level.read_pos(cell_pos.m, cell_pos.n) != '#'
          if (not @position_in_array(cell_pos, corner_deadlock_positions) and 
              not @position_in_array(cell_pos, line_deadlock_positions))
            line_deadlock_positions.push( { m:cell_pos.m, n:cell_pos.n } )
          cell_pos.n = cell_pos.n + 1
          
      ###
      # Test vertical lines
      ###
      
      escape.goal = false
      
      # while cell is not wall
      cell_pos = { m:corner_pos.m, n:corner_pos.n }
      cell = level.read_pos(cell_pos.m, cell_pos.n)
      while cell != '#'
        # If the cell on the left of the actual cell is not wall
        if level.read_pos(cell_pos.m, cell_pos.n - 1) != '#'
          escape.left = true
        # If the cell on the right of the actual cell is not wall
        if level.read_pos(cell_pos.m, cell_pos.n + 1) != '#'
          escape.right = true
        # If cell is goal
        if cell == '.' or cell == '*' or cell == '+'
          escape.goal = true
      
        cell_pos.m = cell_pos.m + 1
        cell = level.read_pos(cell_pos.m, cell_pos.n)
      
      # mark vertical line if left or right is full of walls and has no goal
      if (escape.left == false or escape.right == false) and escape.goal == false
        cell_pos = { m:corner_pos.m, n:corner_pos.n }
        while level.read_pos(cell_pos.m, cell_pos.n) != '#'
          # add cell in deadlock positions if not already added
          if (not @position_in_array(cell_pos, corner_deadlock_positions) and 
              not @position_in_array(cell_pos, line_deadlock_positions))
            line_deadlock_positions.push( { m:cell_pos.m, n:cell_pos.n } )
          cell_pos.m = cell_pos.m + 1
    
    return line_deadlock_positions.concat(corner_deadlock_positions)

  ###
    Get the list of deadlocked boxes 
    @param level (current position of boxes) we want to test
    @return array of deadlocked positions for current level [{m, n}]
  ###
  deadlocked_boxes: (level) ->
    deadlocked_boxes = []
    for pos in @deadlock_positions
      if level.read_pos(pos.m, pos.n) == '$'
        deadlocked_boxes.push(pos)
  
    return deadlocked_boxes
    
  ###
    Did the last push imply a deadlock ?
    @param level (current position of boxes) we want to test
    @param box_position position of the last pushed box {m, n}
    @return deadlocked boxes positions [{m,n},...] if deadlock, false if not
  ###
  deadlocked_last_push: (level, box_position) ->
    deadlocked_positions = []

    ###
    # Last push made a square of boxes/walls
    ###
    
    # neighbours cells
    pos =
      box:   box_position
      left:  { m:box_position.m,   n:box_position.n-1 }
      right: { m:box_position.m,   n:box_position.n+1 }
      down:  { m:box_position.m+1, n:box_position.n }
      up:    { m:box_position.m-1, n:box_position.n }
    
      up_left:    { m:box_position.m-1, n:box_position.n-1 }
      down_left:  { m:box_position.m+1, n:box_position.n-1 }
      up_right:   { m:box_position.m-1, n:box_position.n+1 }
      down_right: { m:box_position.m+1, n:box_position.n+1 }

    cell =
      box:   level.read_pos(pos.box.m,   pos.box.n)
      left:  level.read_pos(pos.left.m,  pos.left.n)
      right: level.read_pos(pos.right.m, pos.right.n)
      down:  level.read_pos(pos.down.m,  pos.down.n)
      up:    level.read_pos(pos.up.m,    pos.up.n)
    
      up_left:    level.read_pos(pos.up_left.m,    pos.up_left.n)
      down_left:  level.read_pos(pos.down_left.m,  pos.down_left.n)
      up_right:   level.read_pos(pos.up_right.m,   pos.up_right.n)
      down_right: level.read_pos(pos.down_right.m, pos.down_right.n)
        
    # up-right square
    deadlocked_positions = @deadlocked_square(cell.box, cell.up, cell.up_right, cell.right,
                                              pos.box,  pos.up,  pos.up_right,  pos.right,
                                              deadlocked_positions)
    
    # up-left square
    deadlocked_positions = @deadlocked_square(cell.box, cell.up, cell.up_left, cell.left,
                                              pos.box,  pos.up,  pos.up_left,  pos.left,
                                              deadlocked_positions)
                                              
    # down-right square
    deadlocked_positions = @deadlocked_square(cell.box, cell.down, cell.down_right, cell.right,
                                              pos.box,  pos.down,  pos.down_right,  pos.right,
                                              deadlocked_positions)
    
    # down-left square
    deadlocked_positions = @deadlocked_square(cell.box, cell.down, cell.down_left, cell.left,
                                              pos.box,  pos.down,  pos.down_left,  pos.left,
                                              deadlocked_positions)
                                                  
    ###
    # Last push made a Z deadlock
    ###
    #  #####   #####   ######   ######
    #  #   #   #   #   # #  #   #  # #
    #  ##O #   # O##   # OO #   # OO #
    #  # O##   ##O #   #  # #   # #  #
    #  #   #   #   #   ######   ######
    #  #####   #####
    
    # fig 1, upper box
    deadlocked_positions = @deadlocked_z(cell.box, cell.down, cell.left, cell.down_right,
                                         pos.box,  pos.down,  deadlocked_positions)
    
#    // fig 1, lower box
#    if(posRight == -1 && posUpLeft == -1
#        && boxesZone->readPos(posUp) == 1)
#      if(goalBox == 0 || goalUp == 0)
#        return true;
#    
#    // fig 2, upper box
#    if(posRight == -1 && posDownLeft == -1
#        && boxesZone->readPos(posDown) == 1)
#      if(goalBox == 0 || goalDown == 0)
#        return true;
#    
#    // fig 2, lower box
#    if(posLeft == -1 && posUpRight == -1
#        && boxesZone->readPos(posUp) == 1)
#      if(goalBox == 0 || goalUp == 0)
#        return true;
#    
#    // fig 3, left box
#    if(posUp == -1 && posDownRight == -1
#        && boxesZone->readPos(posRight) == 1)
#      if(goalBox == 0 || goalRight == 0)
#        return true;
#    
#    // fig 3, right box
#    if(posDown == -1 && posUpLeft == -1
#        && boxesZone->readPos(posLeft) == 1)
#      if(goalBox == 0 || goalLeft == 0)
#        return true;
#    
#    // fig 4, left box
#    if(posDown == -1 && posUpRight == -1
#        && boxesZone->readPos(posRight) == 1)
#      if(goalBox == 0 || goalRight == 0)
#        return true;
#    
#    // fig 4, right box
#    if(posUp == -1 && posDownLeft == -1
#        && boxesZone->readPos(posLeft) == 1)
#      if(goalBox == 0 || goalLeft == 0)
#        return true;
#    
#
    return deadlocked_positions

  ###
    Test a specific deadlocked square and return the deadlocked positions
    @param cell_box letter of the box we want to test ('$' or '*')
    @param pos_box position of the box we want to test
    @param cell1, cell2, cell3 values of cells that made a square with the current box
    @param pos1, pos2, pos3 {m,n} positions of the corresponding cells
    @param deadlocked_positions array of deadlocked boxes positions
    @return completed array of deadlocked_positions (no duplicates positions)
  ###
  deadlocked_square: (cell_box, cell1, cell2, cell3, pos_box, pos1, pos2, pos3, deadlocked_positions) ->    
    if cell_box == '$' and
       (cell1 == '#' or cell1 == '$') and
       (cell2 == '#' or cell2 == '$') and
       (cell3 == '#' or cell3 == '$')
      if not @position_in_array(pos_box, deadlocked_positions)
        deadlocked_positions.push({ m:pos_box.m, n:pos_box.n })
      if not @position_in_array(pos1, deadlocked_positions) and cell1 == '$'
        deadlocked_positions.push({ m:pos1.m, n:pos1.n })
      if not @position_in_array(pos2, deadlocked_positions) and cell2 == '$'
        deadlocked_positions.push({ m:pos2.m, n:pos2.n })
      if not @position_in_array(pos3, deadlocked_positions) and cell3 == '$'
        deadlocked_positions.push({ m:pos3.m, n:pos3.n })
                
    return deadlocked_positions
    
  deadlocked_z: (cell_box, cell_box2, cell_wall1, cell_wall2, pos_box, pos_box2, deadlocked_positions) ->
    if cell_wall1 == '#' and cell_wall2 == '#'
      if (cell_box == '$' || cell_box == '*') and (cell_box2 == '$' || cell_box2 == '*')
        if not (cell_box == '*' and cell_box2 == '*') 
          if not @position_in_array(pos_box, deadlocked_positions)
            deadlocked_positions.push({ m:pos_box.m, n:pos_box.n })
          if not @position_in_array(pos_box2, deadlocked_positions)
            deadlocked_positions.push({ m:pos_box2.m, n:pos_box2.n })
              
    return deadlocked_positions
          
  ###
    return true if position is in a corner of level (corner with 2 walls)
    @param level we want to test
    @param m Row number.
    @param n Col number.
    @return true if (m, n) is in a corner of level, return false if not
  ###
  is_in_corner: (level, m, n) ->
    l = level.read_pos(m, n-1)
    r = level.read_pos(m, n+1)
    u = level.read_pos(m-1, n)
    d = level.read_pos(m+1, n)
    
    (u == '#' && l == '#') || (u == '#' && r == '#')  || (d == '#' && l == '#') || (d == '#' && r == '#')
    
  ###
    find if position is in array of positions
    @param position is a hash like {m:42, n:42}
    @param array_of_positions array of positions
    @return true if position is in array
  ###
  position_in_array: (position, array_of_positions) ->
    for pos in array_of_positions
      if pos.m == position.m and pos.n == position.n
        return true
    return false