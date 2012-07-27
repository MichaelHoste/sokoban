
/*
  Class to deal with deadlocks (situations where the level cannot be resolved)
*/

(function() {

  window.DeadlockCore = (function() {
    /*
        Constructor
        @param level we want to test for deadlocks
    */
    function DeadlockCore(level) {
      this.already_found_deadlocks = [];
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
        Did the last push imply a deadlock ?
        @param level (current position of boxes) we want to test
        @param box_position position of the last pushed box {m, n}
        @param array of already deadlocked positions [{m,n}, ...]
        @return deadlocked boxes positions [{m,n},...] if deadlock, false if not
    */

    DeadlockCore.prototype.deadlocked_last_push = function(level, box_position, deadlocked_positions) {
      /*
          # Last push made a square of boxes/walls
      */
      var cell, deadlock, pos, still_deadlocked, _i, _j, _k, _len, _len2, _len3, _ref;
      pos = {
        box: box_position,
        left: {
          m: box_position.m,
          n: box_position.n - 1
        },
        right: {
          m: box_position.m,
          n: box_position.n + 1
        },
        down: {
          m: box_position.m + 1,
          n: box_position.n
        },
        up: {
          m: box_position.m - 1,
          n: box_position.n
        },
        up_left: {
          m: box_position.m - 1,
          n: box_position.n - 1
        },
        down_left: {
          m: box_position.m + 1,
          n: box_position.n - 1
        },
        up_right: {
          m: box_position.m - 1,
          n: box_position.n + 1
        },
        down_right: {
          m: box_position.m + 1,
          n: box_position.n + 1
        }
      };
      cell = {
        box: level.read_pos(pos.box.m, pos.box.n),
        left: level.read_pos(pos.left.m, pos.left.n),
        right: level.read_pos(pos.right.m, pos.right.n),
        down: level.read_pos(pos.down.m, pos.down.n),
        up: level.read_pos(pos.up.m, pos.up.n),
        up_left: level.read_pos(pos.up_left.m, pos.up_left.n),
        down_left: level.read_pos(pos.down_left.m, pos.down_left.n),
        up_right: level.read_pos(pos.up_right.m, pos.up_right.n),
        down_right: level.read_pos(pos.down_right.m, pos.down_right.n)
      };
      deadlocked_positions = this.deadlocked_square(cell.box, cell.up, cell.up_right, cell.right, pos.box, pos.up, pos.up_right, pos.right, deadlocked_positions);
      deadlocked_positions = this.deadlocked_square(cell.box, cell.up, cell.up_left, cell.left, pos.box, pos.up, pos.up_left, pos.left, deadlocked_positions);
      deadlocked_positions = this.deadlocked_square(cell.box, cell.down, cell.down_right, cell.right, pos.box, pos.down, pos.down_right, pos.right, deadlocked_positions);
      deadlocked_positions = this.deadlocked_square(cell.box, cell.down, cell.down_left, cell.left, pos.box, pos.down, pos.down_left, pos.left, deadlocked_positions);
      /*
          # Last push made a Z deadlock
      */
      deadlocked_positions = this.deadlocked_z(cell.box, cell.down, cell.left, cell.down_right, pos.box, pos.down, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.up, cell.right, cell.up_left, pos.box, pos.up, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.down, cell.right, cell.down_left, pos.box, pos.down, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.up, cell.left, cell.up_right, pos.box, pos.up, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.right, cell.up, cell.down_right, pos.box, pos.right, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.left, cell.down, cell.up_left, pos.box, pos.left, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.right, cell.down, cell.up_right, pos.box, pos.right, deadlocked_positions);
      deadlocked_positions = this.deadlocked_z(cell.box, cell.left, cell.up, cell.down_left, pos.box, pos.left, deadlocked_positions);
      _ref = this.already_found_deadlocks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        deadlock = _ref[_i];
        still_deadlocked = true;
        for (_j = 0, _len2 = deadlock.length; _j < _len2; _j++) {
          pos = deadlock[_j];
          cell = level.read_pos(pos.m, pos.n);
          if (!(cell === '$' || cell === '*' || cell === '#') && still_deadlocked) {
            still_deadlocked = false;
          }
        }
        if (still_deadlocked) {
          for (_k = 0, _len3 = deadlock.length; _k < _len3; _k++) {
            pos = deadlock[_k];
            cell = level.read_pos(pos.m, pos.n);
            if (cell !== '#' && !this.position_in_array(pos, deadlocked_positions)) {
              deadlocked_positions.push({
                m: pos.m,
                n: pos.n
              });
            }
          }
        }
      }
      return deadlocked_positions;
    };

    /*
        Test a specific deadlocked square and return the deadlocked positions
        @param cell_box letter of the box we want to test ('$' or '*')
        @param pos_box position of the box we want to test
        @param cell1, cell2, cell3 values of cells that made a square with the current box
        @param pos1, pos2, pos3 {m,n} positions of the corresponding cells
        @param deadlocked_positions array of deadlocked boxes positions
        @return completed array of deadlocked_positions (no duplicates positions)
    */

    DeadlockCore.prototype.deadlocked_square = function(cell_box, cell1, cell2, cell3, pos_box, pos1, pos2, pos3, deadlocked_positions) {
      if (cell_box === '$' && (cell1 === '#' || cell1 === '$') && (cell2 === '#' || cell2 === '$') && (cell3 === '#' || cell3 === '$')) {
        if (!this.position_in_array(pos_box, deadlocked_positions)) {
          deadlocked_positions.push({
            m: pos_box.m,
            n: pos_box.n
          });
        }
        if (!this.position_in_array(pos1, deadlocked_positions) && cell1 === '$') {
          deadlocked_positions.push({
            m: pos1.m,
            n: pos1.n
          });
        }
        if (!this.position_in_array(pos2, deadlocked_positions) && cell2 === '$') {
          deadlocked_positions.push({
            m: pos2.m,
            n: pos2.n
          });
        }
        if (!this.position_in_array(pos3, deadlocked_positions) && cell3 === '$') {
          deadlocked_positions.push({
            m: pos3.m,
            n: pos3.n
          });
        }
        this.already_found_deadlocks.push([
          {
            m: pos_box.m,
            n: pos_box.n
          }, {
            m: pos1.m,
            n: pos1.n
          }, {
            m: pos2.m,
            n: pos2.n
          }, {
            m: pos3.m,
            n: pos3.n
          }
        ]);
      }
      return deadlocked_positions;
    };

    DeadlockCore.prototype.deadlocked_z = function(cell_box, cell_box2, cell_wall1, cell_wall2, pos_box, pos_box2, deadlocked_positions) {
      if (cell_wall1 === '#' && cell_wall2 === '#') {
        if ((cell_box === '$' || cell_box === '*') && (cell_box2 === '$' || cell_box2 === '*')) {
          if (!(cell_box === '*' && cell_box2 === '*')) {
            if (!this.position_in_array(pos_box, deadlocked_positions)) {
              deadlocked_positions.push({
                m: pos_box.m,
                n: pos_box.n
              });
            }
            if (!this.position_in_array(pos_box2, deadlocked_positions)) {
              deadlocked_positions.push({
                m: pos_box2.m,
                n: pos_box2.n
              });
            }
            this.already_found_deadlocks.push([
              {
                m: pos_box.m,
                n: pos_box.n
              }, {
                m: pos_box2.m,
                n: pos_box2.n
              }
            ]);
          }
        }
      }
      return deadlocked_positions;
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

}).call(this);
