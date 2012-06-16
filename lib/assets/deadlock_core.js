
  /*
    Class to deal with deadlocks (situations where the level cannot be resolved)
  */

  window.DeadlockCore = (function() {

    /*
        Constructor
        @param level we want to test for deadlocks
    */

    function DeadlockCore(level) {
      this.deadlock_positions = this.create_deadlock_positions(level);
    }

    /*
        Create list of deadlocked positions of the level (corners, lines etc.)
        A deadlocked position is a position that makes impossible to solve the level when a box is on it
        @param level we want to test for deadlocks
        @return array of deadlocked positions for the level (corners, lines etc.)
    */

    DeadlockCore.prototype.create_deadlock_positions = function(level) {
      var deadlock_positions;
      deadlock_positions = this.create_corner_deadlock_positions(level);
      deadlock_positions = this.create_line_deadlock_positions(level, deadlock_positions);
      return deadlock_positions;
    };

    /*
        This function add corner deadlocks to deadlock zone. This happened when
        a box is in a corner made by walls
        @param level we want to test for corner deadlocks
        @return array of corner deadlock positions
    */

    DeadlockCore.prototype.create_corner_deadlock_positions = function(level) {
      var deadlock_positions, m, n, pos, _ref, _ref2;
      deadlock_positions = [];
      for (m = 0, _ref = level.rows_number - 1; 0 <= _ref ? m <= _ref : m >= _ref; 0 <= _ref ? m++ : m--) {
        for (n = 0, _ref2 = level.cols_number - 1; 0 <= _ref2 ? n <= _ref2 : n >= _ref2; 0 <= _ref2 ? n++ : n--) {
          pos = level.read_pos(m, n);
          if (pos !== ' ' && pos !== '#' && pos !== '.' && pos !== '*' && pos !== '+') {
            if (this.is_in_corner(level, m, n)) {
              deadlock_positions.push({
                m: m,
                n: n
              });
            }
          }
        }
      }
      return deadlock_positions;
    };

    /*
        This method add line deadlocks to deadlock zone. This happened when
        there is a box next a wall and no way to remove it (escape move)
        You must apply this function AFTER having use the method
        create_corner_deadlock_positions because we need corner positions.
        @param level we want to test for line deadlocks
        @param corner_deadlock_positions list of corner deadlock positions
        @return array of corner and line deadlock positions
    */

    DeadlockCore.prototype.create_line_deadlock_positions = function(level, corner_deadlock_positions) {
      var cell, cell_pos, corner_pos, escape, line_deadlock_positions, _i, _len;
      line_deadlock_positions = [];
      for (_i = 0, _len = corner_deadlock_positions.length; _i < _len; _i++) {
        corner_pos = corner_deadlock_positions[_i];
        escape = {
          up: false,
          down: false,
          left: false,
          right: false,
          goal: false
        };
        /*
              # Test horizontal lines
        */
        cell_pos = {
          m: corner_pos.m,
          n: corner_pos.n
        };
        cell = level.read_pos(cell_pos.m, cell_pos.n);
        while (cell !== '#') {
          if (level.read_pos(cell_pos.m - 1, cell_pos.n) !== '#') escape.up = true;
          if (level.read_pos(cell_pos.m + 1, cell_pos.n) !== '#') {
            escape.down = true;
          }
          if (cell === '.' || cell === '*' || cell === '+') escape.goal = true;
          cell_pos.n = cell_pos.n + 1;
          cell = level.read_pos(cell_pos.m, cell_pos.n);
        }
        if ((escape.up === false || escape.down === false) && escape.goal === false) {
          cell_pos = {
            m: corner_pos.m,
            n: corner_pos.n
          };
          while (level.read_pos(cell_pos.m, cell_pos.n) !== '#') {
            if (!this.position_in_array(cell_pos, corner_deadlock_positions) && !this.position_in_array(cell_pos, line_deadlock_positions)) {
              line_deadlock_positions.push({
                m: cell_pos.m,
                n: cell_pos.n
              });
            }
            cell_pos.n = cell_pos.n + 1;
          }
        }
        /*
              # Test vertical lines
        */
        escape.goal = false;
        cell_pos = {
          m: corner_pos.m,
          n: corner_pos.n
        };
        cell = level.read_pos(cell_pos.m, cell_pos.n);
        while (cell !== '#') {
          if (level.read_pos(cell_pos.m, cell_pos.n - 1) !== '#') {
            escape.left = true;
          }
          if (level.read_pos(cell_pos.m, cell_pos.n + 1) !== '#') {
            escape.right = true;
          }
          if (cell === '.' || cell === '*' || cell === '+') escape.goal = true;
          cell_pos.m = cell_pos.m + 1;
          cell = level.read_pos(cell_pos.m, cell_pos.n);
        }
        if ((escape.left === false || escape.right === false) && escape.goal === false) {
          cell_pos = {
            m: corner_pos.m,
            n: corner_pos.n
          };
          while (level.read_pos(cell_pos.m, cell_pos.n) !== '#') {
            if (!this.position_in_array(cell_pos, corner_deadlock_positions) && !this.position_in_array(cell_pos, line_deadlock_positions)) {
              line_deadlock_positions.push({
                m: cell_pos.m,
                n: cell_pos.n
              });
            }
            cell_pos.m = cell_pos.m + 1;
          }
        }
      }
      return line_deadlock_positions.concat(corner_deadlock_positions);
    };

    /*
        Get the list of deadlocked boxes 
        @param level (current position of boxes) we want to test
        @return array of deadlocked positions for current level [{m, n}]
    */

    DeadlockCore.prototype.deadlocked_boxes = function(level) {
      var deadlocked_boxes, pos, _i, _len, _ref;
      deadlocked_boxes = [];
      _ref = this.deadlock_positions;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pos = _ref[_i];
        if (level.read_pos(pos.m, pos.n) === '$') deadlocked_boxes.push(pos);
      }
      return deadlocked_boxes;
    };

    /*
        return true if position is in a corner of level (corner with 2 walls)
        @param level we want to test
        @param m Row number.
        @param n Col number.
        @return true if (m, n) is in a corner of level, return false if not
    */

    DeadlockCore.prototype.is_in_corner = function(level, m, n) {
      var d, l, r, u;
      l = level.read_pos(m, n - 1);
      r = level.read_pos(m, n + 1);
      u = level.read_pos(m - 1, n);
      d = level.read_pos(m + 1, n);
      return (u === '#' && l === '#') || (u === '#' && r === '#') || (d === '#' && l === '#') || (d === '#' && r === '#');
    };

    /*
        find if position is in array of positions
        @param position is a hash like {m:42, n:42}
        @param array_of_positions array of positions
        @return true if position is in array
    */

    DeadlockCore.prototype.position_in_array = function(position, array_of_positions) {
      var pos, _i, _len;
      for (_i = 0, _len = array_of_positions.length; _i < _len; _i++) {
        pos = array_of_positions[_i];
        if (pos.m === position.m && pos.n === position.n) return true;
      }
      return false;
    };

    return DeadlockCore;

  })();
