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
    return corner_deadlock_positions
  
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
    
    (u == '#' && l == '#') || (u == '#' && r == '#')	|| (d == '#' && l == '#') || (d == '#' && r == '#')