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
      # Test horizontal line
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
          if not @position_in_array(cell_pos, corner_deadlock_positions) and not @position_in_array(cell_pos, line_deadlock_positions)
            line_deadlock_positions.push( { m:cell_pos.m, n:cell_pos.n } )
          cell_pos.n = cell_pos.n + 1
    
    return line_deadlock_positions.concat(corner_deadlock_positions)

#     /**********************/
#     /* Test vertical line */
#     /**********************/
#     tempLevelPos = cLevelPos;
#
#     tempZonePos = levelToZonePos[tempLevelPos];
#     tempCar = level->readPos(tempLevelPos);
#
#     // while cell is...
#     while(tempZonePos != -1          // ...not wall...
#        && tempCar != '.' && tempCar != '*')  // ...and not goal
#     {
#       // If the cell just above the actual cell is not wall
#       if(levelToZonePos[tempLevelPos-1] != -1)
#         leftEscape = true;
#       if(levelToZonePos[tempLevelPos+1] != -1)
#         rightEscape = true;
#
#       if(leftEscape && rightEscape)
#         break;
#
#       tempLevelPos+=nCols;
#       tempZonePos = levelToZonePos[tempLevelPos];
#       tempCar = level->readPos(tempLevelPos);
#     }
#
#     // mark horizontal line if up or down is full of walls
#     if(tempZonePos == -1)
#     {
#       tempLevelPos = cLevelPos+nCols;
#       tempZonePos = levelToZonePos[tempLevelPos];
#       tempCar = level->readPos(tempLevelPos);
#       while(tempZonePos != -1)
#       {
#         write1ToPos(tempZonePos);
#         tempLevelPos+=nCols;
#         tempZonePos = levelToZonePos[tempLevelPos];
#         tempCar = level->readPos(tempLevelPos);
#       }
#     }
#   }
#
#   free(cornerPos);

  ###
    Get the list of deadlocked boxes 
    @param level (current position of boxes) we want to test
    @return array of deadlocked positions for current level [{m, n}]
  ###
  deadlocked_boxes: (level) ->
    deadlocked_boxes = []
    for pos in @deadlock_positions
      if level.read_pos(pos.m, pos.n) == '$'
        deadlocked_boxes.push( pos )
  
    return deadlocked_boxes
  
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