
  /*
  brief Class containing a level and every methods about it
  
  Positions in grid start in the upper-left corner with (m=0,n=0).
  
  Example : (2,4) means third rows and fifth cols starting in the upper-left
  corner.
  
  Grid is made like this in loaded files :
  */

  window.LevelCore = (function() {

    function LevelCore() {
      this.pack_name = "";
      this.level_name = "";
      this.copyright = "";
      this.grid = [];
      this.boxes_number = 0;
      this.goals_number = 0;
      this.rows_number = 0;
      this.cols_number = 0;
      this.pusher_pos_m = 0;
      this.pusher_pos_n = 0;
    }

    LevelCore.prototype.create_from_remote_file = function(pack_name, level_name) {
      return this.xml_load(pack_name, level_name);
    };

    LevelCore.prototype.create_from_scratch = function(lines, width, height, pack_name, level_name, copyright) {
      if (copyright == null) copyright = "";
      return this.level_from_scratch(lines, width, height, pack_name, level_name, copyright);
    };

    /*
        Read the value of position (m,n).
        Position start in the upper-left corner of the grid with (0,0).
        @param m Row number.
        @param n Col number.
        @return Value of position (m,n) or 'E' if pos is out of grid.
    */

    LevelCore.prototype.read_pos = function(m, n) {
      if (m < this.rows_number && n < this.cols_number && m >= 0 && n >= 0) {
        return this.grid[this.cols_number * m + n];
      } else {
        return 'E';
      }
    };

    /*
        Write the value of letter in position (m,n).
        Position start in the upper-left corner of the grid with (0,0).
        @param m Row number.
        @param n Col number.
        @param letter value to assign at (m,n) in the grid
    */

    LevelCore.prototype.write_pos = function(m, n, letter) {
      if (m < this.rows_number && n < this.cols_number && m >= 0 && n >= 0) {
        return this.grid[this.cols_number * m + n] = letter;
      }
    };

    /*
        Look if pusher can move in a given direction
        @param direction 'u', 'd', 'l', 'r' in lowercase and uppercase
        @return true if pusher can move in this direction, false if not.
    */

    LevelCore.prototype.pusher_can_move = function(direction) {
      var m, mouv1, mouv2, n;
      mouv1 = ' ';
      mouv2 = ' ';
      m = this.pusher_pos_m;
      n = this.pusher_pos_n;
      if (direction === 'u') {
        mouv1 = this.read_pos(m - 1, n);
        mouv2 = this.read_pos(m - 2, n);
      } else if (direction === 'd') {
        mouv1 = this.read_pos(m + 1, n);
        mouv2 = this.read_pos(m + 2, n);
      } else if (direction === 'l') {
        mouv1 = this.read_pos(m, n - 1);
        mouv2 = this.read_pos(m, n - 2);
      } else if (direction === 'r') {
        mouv1 = this.read_pos(m, n + 1);
        mouv2 = this.read_pos(m, n + 2);
      }
      if (mouv1 === '#' || ((mouv1 === '*' || mouv1 === '$') && (mouv2 === '*' || mouv2 === '$' || mouv2 === '#'))) {
        return false;
      } else {
        return true;
      }
    };

    /*
        Move the pusher in a given direction and save it in the actualPath
        @param direction Direction where to move the pusher (u,d,l,r,U,D,L,R)
        @return 0 if no move.
                1 if normal move.
                2 if box push.
    */

    LevelCore.prototype.move = function(direction) {
      var action, m, m_1, m_2, n, n_1, n_2, state;
      action = 1;
      m = this.pusher_pos_m;
      n = this.pusher_pos_n;
      direction = direction.toLowerCase();
      if (direction === 'u' && this.pusher_can_move('u')) {
        m_1 = m - 1;
        m_2 = m - 2;
        n_1 = n_2 = n;
        this.pusher_pos_m--;
      } else if (direction === 'd' && this.pusher_can_move('d')) {
        m_1 = m + 1;
        m_2 = m + 2;
        n_1 = n_2 = n;
        this.pusher_pos_m++;
      } else if (direction === 'l' && this.pusher_can_move('l')) {
        n_1 = n - 1;
        n_2 = n - 2;
        m_1 = m_2 = m;
        this.pusher_pos_n--;
      } else if (direction === 'r' && this.pusher_can_move('r')) {
        n_1 = n + 1;
        n_2 = n + 2;
        m_1 = m_2 = m;
        this.pusher_pos_n++;
      } else {
        action = 0;
        state = 0;
      }
      if (action === 1) {
        state = 1;
        if (this.read_pos(m, n) === '+') {
          this.write_pos(m, n, '.');
        } else {
          this.write_pos(m, n, 's');
        }
        if (this.read_pos(m_1, n_1) === '$' || this.read_pos(m_1, n_1) === '*') {
          if (this.read_pos(m_2, n_2) === '.') {
            this.write_pos(m_2, n_2, '*');
          } else {
            this.write_pos(m_2, n_2, '$');
          }
          state = 2;
        }
        if (this.read_pos(m_1, n_1) === '.' || this.read_pos(m_1, n_1) === '*') {
          this.write_pos(m_1, n_1, '+');
        } else {
          this.write_pos(m_1, n_1, '@');
        }
      }
      return state;
    };

    /*
        Move the pusher backward and erase last move in the path
        @return 0 if no move.
                1 if normal move.
                2 if box move.
    */

    LevelCore.prototype.delete_last_move = function(path) {
      var action, direction, m, m_1, m_2, maj, n, n_1, n_2, state;
      action = 1;
      maj = 0;
      m = this.pusher_pos_m;
      n = this.pusher_pos_n;
      direction = path.get_last_move();
      state = 1;
      if (direction === 'U' || direction === 'D' || direction === 'L' || direction === 'R') {
        maj = 1;
        state = 2;
      }
      if (direction === 'u' || direction === 'U') {
        m_1 = m - 1;
        m_2 = m + 1;
        n_1 = n_2 = n;
        this.pusher_pos_m++;
      } else if (direction === 'd' || direction === 'D') {
        m_1 = m + 1;
        m_2 = m - 1;
        n_1 = n_2 = n;
        this.pusher_pos_m--;
      } else if (direction === 'l' || direction === 'L') {
        n_1 = n - 1;
        n_2 = n + 1;
        m_1 = m_2 = m;
        this.pusher_pos_n++;
      } else if (direction === 'r' || direction === 'R') {
        n_1 = n + 1;
        n_2 = n - 1;
        m_1 = m_2 = m;
        this.pusher_pos_n--;
      } else {
        action = 0;
        state = 0;
      }
      if (action === 1) {
        if (this.read_pos(m_2, n_2) === '.') {
          this.write_pos(m_2, n_2, '+');
        } else {
          this.write_pos(m_2, n_2, '@');
        }
        if (this.read_pos(m_1, n_1) === '*' && maj === 1) {
          this.write_pos(m_1, n_1, '.');
        } else if (this.read_pos(m_1, n_1) === '$' && maj === 1) {
          this.write_pos(m_1, n_1, 's');
        }
        if (this.read_pos(m, n) === '+' && maj === 0) {
          this.write_pos(m, n, '.');
        } else if (this.read_pos(m, n) === '@' && maj === 0) {
          this.write_pos(m, n, 's');
        } else if (this.read_pos(m, n) === '+' && maj === 1) {
          this.write_pos(m, n, '*');
        } else if (this.read_pos(m, n) === '@' && maj === 1) {
          this.write_pos(m, n, '$');
        }
      }
      path.delete_last_move();
      return state;
    };

    /*
        Return true if all boxes are in their goals.
        @return true if all boxes are in their goals, false if not
    */

    LevelCore.prototype.is_won = function() {
      var i, _ref;
      for (i = 0, _ref = this.rowsNumber * this.colsNumber - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        if (grid[i] === '$') return false;
      }
      return true;
    };

    /*
        Initialize (find) starting position of pusher to store it in this object
    */

    LevelCore.prototype.initialize_pusher_position = function() {
      var cell, find, i, _len, _ref, _results;
      find = false;
      _ref = this.grid;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        cell = _ref[i];
        if (!find && (cell === '@' || cell === '+')) {
          this.pusher_pos_n = i % this.cols_number;
          this.pusher_pos_m = Math.floor(i / this.cols_number);
          _results.push(find = true);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    /*
        Transform empty spaces inside level in floor represented by 's' used
        to draw the level. Call to recursive function "makeFloorRec".
    */

    LevelCore.prototype.make_floor = function() {
      var cell, i, _len, _ref, _results;
      this.make_floor_rec(this.pusher_pos_m, this.pusher_pos_n);
      _ref = this.grid;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        cell = _ref[i];
        if (cell === 'p') {
          _results.push(this.grid[i] = '.');
        } else if (cell === 'd') {
          _results.push(this.grid[i] = '$');
        } else if (cell === 'a') {
          _results.push(this.grid[i] = '*');
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    /*
        Recursive function used to transform inside spaces by floor ('s')
        started with initial position of sokoban.
        NEVER use this function directly. Use make_floor instead.
        @param m Rows number (start with sokoban position)
        @param n Cols number (start with sokoban position)
    */

    LevelCore.prototype.make_floor_rec = function(m, n) {
      var a;
      a = this.read_pos(m, n);
      if (a === ' ') {
        this.write_pos(m, n, 's');
      } else if (a === '.') {
        this.write_pos(m, n, 'p');
      } else if (a === '$') {
        this.write_pos(m, n, 'd');
      } else if (a === '*') {
        this.write_pos(m, n, 'a');
      }
      if (a !== '#' && a !== 's' && a !== 'p' && a !== 'd' && a !== 'a') {
        this.make_floor_rec(m + 1, n);
        this.make_floor_rec(m - 1, n);
        this.make_floor_rec(m, n + 1);
        return this.make_floor_rec(m, n - 1);
      }
    };

    /*
        Print the level in the javascript console
    */

    LevelCore.prototype.print = function() {
      var line, m, n, _ref, _ref2, _results;
      _results = [];
      for (m = 0, _ref = this.rows_number - 1; 0 <= _ref ? m <= _ref : m >= _ref; 0 <= _ref ? m++ : m--) {
        line = "";
        for (n = 0, _ref2 = this.cols_number - 1; 0 <= _ref2 ? n <= _ref2 : n >= _ref2; 0 <= _ref2 ? n++ : n--) {
          line = line + this.read_pos(m, n);
        }
        _results.push(console.log(line + '\n'));
      }
      return _results;
    };

    /*
        Load a specific level in a XML pack
    */

    LevelCore.prototype.xml_load = function(pack_name, level_name) {
      this.pack_name = pack_name;
      this.level_name = level_name;
      return $.ajax({
        type: "GET",
        url: "./levels/" + this.pack_name + ".slc",
        dataType: "xml",
        success: this.xml_parser,
        async: false,
        context: this
      });
    };

    /* 
      take the xml buffer of a pack (callback of "xml_load") and load 
      the "id" level in it (where id is the string name of level)
      @param xml the buffer (callback of xml_load)
    */

    LevelCore.prototype.xml_parser = function(xml) {
      var copyright, i, j, line, lines, text, xml_level, _len, _ref, _ref2;
      xml_level = $(xml).find('Level[Id="' + this.level_name + '"]');
      this.rows_number = $(xml_level).attr("Height");
      this.cols_number = $(xml_level).attr("Width");
      if (copyright = $(xml_level).attr("Copyright")) this.copyright = copyright;
      for (i = 0, _ref = this.rows_number * this.cols_number - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        this.grid[i] = ' ';
      }
      lines = $(xml_level).find("L");
      for (i = 0, _len = lines.length; i < _len; i++) {
        line = lines[i];
        text = $(line).text();
        for (j = 0, _ref2 = text.length - 1; 0 <= _ref2 ? j <= _ref2 : j >= _ref2; 0 <= _ref2 ? j++ : j--) {
          this.grid[this.cols_number * i + j] = text.charAt(j);
        }
      }
      return this.initialize_level_properties();
    };

    LevelCore.prototype.level_from_scratch = function(lines, width, height, pack_name, level_name, copyright) {
      var i, j, line, _len, _ref;
      if (copyright == null) copyright = "";
      this.pack_name = pack_name;
      this.level_name = level_name;
      this.copyright = copyright;
      this.rows_number = height;
      this.cols_number = width;
      for (i = 0, _len = lines.length; i < _len; i++) {
        line = lines[i];
        for (j = 0, _ref = line.length - 1; 0 <= _ref ? j <= _ref : j >= _ref; 0 <= _ref ? j++ : j--) {
          this.grid[this.cols_number * i + j] = line.charAt(j);
        }
      }
      return this.initialize_level_properties();
    };

    LevelCore.prototype.initialize_level_properties = function() {
      var cell, _i, _len, _ref, _results;
      this.initialize_pusher_position();
      this.make_floor();
      _ref = this.grid;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        if (cell === '*' || cell === '$') {
          this.boxes_number = this.boxes_number + 1;
        }
        if (cell === '+' || cell === '*' || cell === '.') {
          _results.push(this.goals_number = this.goals_number + 1);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return LevelCore;

  })();
