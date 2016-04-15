
/*
  Class usefull to represent a way to move in a level.
  
  Pushes are represented by upper case and moves by lower case
  It could be written in COMPRESSED mode, but in this class, it's
  UNCOMPRESSED for rapidity and flexibility.
  
  In compressed mode, when many moves in one direction, letters are prefixed
  by numbers.
  
  example uncompressed mode : rrrllUUUUUruLLLdlluRRRRdr
  example compressed mode : 3r2l5Uru3Ld2lu4Rdr
 */

(function() {
  window.PathCore = (function() {
    function PathCore() {
      this.n_pushes = 0;
      this.n_moves = 0;
      this.moves = [];
    }


    /*
      Constructor from an uncompressed path
      @param uncompressed_path (string)
     */

    PathCore.prototype.create_from_uncompressed = function(uncompressed_path) {
      var i, l, ref, results;
      this.n_pushes = 0;
      this.n_moves = 0;
      this.moves = [];
      results = [];
      for (i = l = 0, ref = uncompressed_path.length - 1; 0 <= ref ? l <= ref : l >= ref; i = 0 <= ref ? ++l : --l) {
        results.push(this.add_displacement(uncompressed_path[i]));
      }
      return results;
    };


    /*
      Constructor from a compressed path
      @param compressed_path (string)
     */

    PathCore.prototype.create_from_compressed = function(compressed_path) {
      var cmpr_moves, i, l, len, m, move, ref, results, uncmpr_moves;
      this.n_pushes = 0;
      this.n_moves = 0;
      this.moves = [];
      cmpr_moves = [];
      uncmpr_moves = [];
      for (i = l = 0, ref = compressed_path.length - 1; 0 <= ref ? l <= ref : l >= ref; i = 0 <= ref ? ++l : --l) {
        cmpr_moves.push(compressed_path[i]);
      }
      uncmpr_moves = this.uncompress_path(cmpr_moves);
      results = [];
      for (m = 0, len = uncmpr_moves.length; m < len; m++) {
        move = uncmpr_moves[m];
        results.push(this.add_displacement(move));
      }
      return results;
    };


    /*
      Add move in a direction
      @param direction direction where the pusher move
     */

    PathCore.prototype.add_move = function(direction) {
      if (this.is_valid_direction(direction)) {
        this.n_moves++;
        return this.moves.push(direction.toLowerCase());
      }
    };


    /*
      Add push in a direction
      @param direction direction where pusher push a box
     */

    PathCore.prototype.add_push = function(direction) {
      if (this.is_valid_direction(direction)) {
        this.n_moves++;
        this.n_pushes++;
        return this.moves.push(direction.toUpperCase());
      }
    };


    /*
      Add displacement in a direction.
      push or move is automatically assigned following of the letter-case of direction
      @param direction direction where pusher push a box
     */

    PathCore.prototype.add_displacement = function(direction) {
      if (this.is_valid_direction(direction)) {
        if (direction >= 'A' && direction <= 'Z') {
          this.n_pushes++;
        }
        this.n_moves++;
        return this.moves.push(direction);
      }
    };


    /*
      Get letter of last action (can be move or push)
      @return letter or false if not last move
     */

    PathCore.prototype.get_last_move = function() {
      if (this.moves.length > 0) {
        return this.moves[this.moves.length - 1];
      } else {
        return false;
      }
    };


    /*
      Delete last move or push
     */

    PathCore.prototype.delete_last_move = function() {
      var last_move;
      if (this.n_moves > 0) {
        last_move = this.moves.pop();
        if (last_move >= 'A' && last_move <= 'Z') {
          this.n_pushes--;
        }
        return this.n_moves--;
      }
    };


    /*
      print path
     */

    PathCore.prototype.print = function() {
      return this.print_uncompressed();
    };


    /*
      Print uncompressed path of this object
     */

    PathCore.prototype.print_uncompressed = function() {
      var l, len, line, move, ref;
      line = "";
      ref = this.moves;
      for (l = 0, len = ref.length; l < len; l++) {
        move = ref[l];
        line = line + move;
      }
      return console.log(line);
    };


    /*
      Print compressed path of this object
     */

    PathCore.prototype.print_compressed = function() {
      var compressed_moves, l, len, line, move;
      compressed_moves = this.compress_path(this.moves);
      line = "";
      for (l = 0, len = compressed_moves.length; l < len; l++) {
        move = compressed_moves[l];
        line = line + move;
      }
      return console.log(line);
    };


    /*
      Get the string path
      @return uncompressed string path
     */

    PathCore.prototype.get_uncompressed_string_path = function() {
      var l, len, line, move, ref;
      line = "";
      ref = this.moves;
      for (l = 0, len = ref.length; l < len; l++) {
        move = ref[l];
        line = line + move;
      }
      return line;
    };


    /*
      Get the string path
      @return compressed string path
     */

    PathCore.prototype.get_compressed_string_path = function() {
      var compressed_moves, l, len, line, move;
      compressed_moves = this.compress_path(this.moves);
      line = "";
      for (l = 0, len = compressed_moves.length; l < len; l++) {
        move = compressed_moves[l];
        line = line + move;
      }
      return line;
    };


    /*
      Is a direction valid (u,d,r,l,U,D,R,L)
      @param direction direction to test
      @return true if valid, false if not
     */

    PathCore.prototype.is_valid_direction = function(direction) {
      var d;
      d = direction.toLowerCase();
      return d === 'u' || d === 'd' || d === 'l' || d === 'r';
    };


    /*
      Compress a path (see description of class)
      @param path uncompressed path
      @return compressed path (array)
     */

    PathCore.prototype.compress_path = function(uncompressed_path) {
      var compressed_path, cpt_c, i, j, k, l, length, ref, tabi;
      cpt_c = 1;
      compressed_path = [];
      length = uncompressed_path.length;
      i = 0;
      while (i < length) {
        j = 0;
        tabi = uncompressed_path[i];
        while (tabi === uncompressed_path[i] && i < length) {
          j = j + 1;
          i = i + 1;
        }
        if (j >= 2) {
          for (k = l = 0, ref = j.toString().length - 1; 0 <= ref ? l <= ref : l >= ref; k = 0 <= ref ? ++l : --l) {
            compressed_path.push(j.toString().substr(k, 1));
          }
        }
        compressed_path.push(tabi);
      }
      return compressed_path;
    };


    /*
      Uncompress a path (see description of Path class)
      @param path compressed path
      @return uncompressed path (array)
     */

    PathCore.prototype.uncompress_path = function(compressed_path) {
      var cell, i, j, l, len, letter, m, nbr, nbr_buffer, nbr_string, ref, uncompressed_path;
      i = 0;
      uncompressed_path = [];
      while (i < compressed_path.length) {
        cell = compressed_path[i];
        nbr_buffer = [];
        if (cell < '0' || cell > '9') {
          nbr_buffer.push('1');
        }
        while (cell >= '0' && cell <= '9') {
          nbr_buffer.push(cell);
          i = i + 1;
          cell = compressed_path[i];
        }
        nbr_string = "";
        for (l = 0, len = nbr_buffer.length; l < len; l++) {
          letter = nbr_buffer[l];
          nbr_string = nbr_string + ("" + letter);
        }
        nbr = parseInt(nbr_string);
        for (j = m = 0, ref = nbr - 1; 0 <= ref ? m <= ref : m >= ref; j = 0 <= ref ? ++m : --m) {
          uncompressed_path.push(compressed_path[i]);
        }
        i = i + 1;
      }
      return uncompressed_path;
    };

    return PathCore;

  })();

}).call(this);
