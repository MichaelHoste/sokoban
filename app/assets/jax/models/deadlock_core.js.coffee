###
  Class to deal with deadlocks (situations where the level cannot be resolved)
###

class window.DeadlockCore

  ###
    Constructor
    @param level we want to test for deadlocks
  ###
  constructor: (level) ->
    @level = level
    # array of positions where a box trigger a deadlock situation
    @deadlock_positions = @create_deadlock_positions()

  ###
    Create list of deadlocked positions of the level (corners, lines etc.)
  ###
  create_deadlock_positions: ->
    deadlock_positions = @create_corner_deadlock_positions()
    #deadlock_positions = @create_line_deadlock_positions(deadlock_positions)
    return deadlock_positions
      
  ###
    This function add corner deadlocks to deadlock zone. This happened when
    a box is in a corner made by walls
    @return array of corner deadlock positions
  ###
  create_corner_deadlock_positions: ->
    deadlock_positions = []
    
    for m in [0..@level.rows_number-1]
      for n in [0..@level.cols_number-1]
        pos = @level.read_pos(m, n)
        # If not outside, not wall, not goal and in a corner, add the position in the deadlock array
        if pos != ' ' && pos != '#' && pos != '.' && pos != '*' && pos != '+'
          if @is_in_corner(m, n)
            deadlock_positions.push( {m: m, n: n} )
    
    return deadlock_positions
         
  ###
    This method add line deadlocks to deadlock zone. This happened when
    there is a box next a wall and no way to remove it (escape move)
    You must apply this function AFTER having use the method
    create_corner_deadlock_positions because we need corner positions.
    @param corner_deadlock_positions list of corner deadlock positions
    @return array of corner and line deadlock positions
  ###
  create_line_deadlock_positions: (corner_deadlock_positions) ->
    
  ###
    return true if position is in a corner of level (corner with 2 walls)
    @param m Row number.
    @param n Col number.
    @return true if (m, n) is in a corner of level, return false if not
  ###
  is_in_corner: (m, n) ->
    l = @level.read_pos(m, n-1)
    r = @level.read_pos(m, n+1)
    u = @level.read_pos(m-1, n)
    d = @level.read_pos(m+1, n)
    
    (u == '#' && l == '#') || (u == '#' && r == '#')	|| (d == '#' && l == '#') || (d == '#' && r == '#')