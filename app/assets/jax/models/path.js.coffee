###
  Class usefull to represent a way to move in a level.
  
  Pushes are represented by upper case and moves by lower case
  It could be written in COMPRESSED mode, but in this class, it's
  UNCOMPRESSED for rapidity and flexibility.
  
  In compressed mode, when many moves in one direction, letters are prefixed
  by numbers.
  
  example uncompressed mode : rrrllUUUUUruLLLdlluRRRRdr
  example compressed mode : 3r2l5Uru3Ld2lu4Rdr
###

Jax.getGlobal()['Path'] = Jax.Model.create

  # Constructor for a empty path
  after_initialize: ->
    @n_pushes   = 0
    @n_moves    = 0
    @moves      = []

  ###
    Add move in a direction
    @param direction direction where the pusher move
  ###
  add_move: (direction) ->
    if @is_valid_direction(direction)
      @n_moves++
      @moves.push(direction.toLowerCase())

  ###
    Add push in a direction
    @param direction direction where pusher push a box
  ###
  add_push: (direction) ->
    if @is_valid_direction(direction)
      @n_moves++
      @n_pushes++
      @moves.push(direction.toUpperCase())
  
  ###
    Add displacement in a direction.
    push or move is automatically assigned following of the letter-case of direction
    @param direction direction where pusher push a box
  ###
  add_displacement: (direction) ->
    if @is_valid_direction(direction)
      if direction >= 'A' and direction <= 'Z'
        @n_pushes++
      else
        @n_moves++
      @moves.push(direction.toUpperCase())
  
  ###
    Get last move or push
  ###
  get_last_move: ->
    last_move = @moves[@moves.length - 1]
      
  ###
    Delete last move or push
  ###
  delete_last_move: ->
    if @n_moves > 0
      last_move = @moves.pop()
      if last_move >= 'A' and last_move <= 'Z'
        @n_pushes--
      @n_moves--
      
  ###
    print path
  ###
  print: ->
    @print_uncompressed()
  
  ###
    Print uncompressed path of this object
  ###
  print_uncompressed: ->
    line = ""
    for move in @moves
      line = line + move
    console.log(line)
    
  ###
    Print compressed path of this object
  ###
  print_compressed: ->
    compressed_moves = @compress_path(@moves)
    line = ""
    for move in compressed_moves
      line = line + move
    console.log(line)
  
  ###
    Is a direction valid (u,d,r,l,U,D,R,L)
    @param direction direction to test
    @return true if valid, false if not
  ###
  is_valid_direction: (direction) ->
    d = direction.toLowerCase()
    return (d == 'u' || d == 'd' || d == 'l' || d == 'r')
  
  ###
    Compress a path (see description of class)
    @param path uncompressed path
    @return compressed path
  ###
  compress_path: (uncompressed_path) ->
    cpt_c = 1
    compressed_path = []
  
    # We loop on each cell of the uncompressed path
    length = uncompressed_path.length
    i = 0
    while i < length
      j = 0
      tabi = uncompressed_path[i]
      
      # while it's the same displacement and we're not in the end
      while tabi == uncompressed_path[i] && i < length
        # (Identical moves)++
        j = j + 1
        i = i + 1

      # If there are many moves in one direction 
      if j >= 2
        for k in [0..j.toString().length-1]
          compressed_path.push(j.toString().substr(k, 1))
  
      # In every case, add direction and '\0' next to it
      compressed_path.push(tabi)
  
    return compressed_path
  
# /**
#  * Uncompress a path (see description of Path class)
#  * @param path compressed path
#  * @return uncompressed path
#  */
#  char* Path::uncompressPath(const char * compressedPath)
#  {
#   int i=0, j=0, nbr;
#   char buffer[10];
#   int cpt=1;
#   char * uncompressedPath;
#  
#   // Alloc empty cell
#   uncompressedPath=(char*)malloc(1*sizeof(char));
#   uncompressedPath[0]='\0';
#  
#   // While we're not in the end of compressed path
#   while(compressedPath[i]!='\0')
#   {
#     buffer[0]='1';
#     buffer[1]='\0';
#  
#     // we put decimal in buffer
#     while(Util::isDecimal(compressedPath[i]))
#     {
#       buffer[j]=compressedPath[i];
#       buffer[j+1]='\0';
#       j++;
#       i++;
#     }
#  
#     // we get decimal on untextual mode
#     nbr=atoi(buffer);
#  
#     for(j=0;j<nbr;j++)
#     {
#       cpt++;
#       uncompressedPath=(char*)realloc(uncompressedPath, cpt*sizeof(char));
#       uncompressedPath[cpt-2]=compressedPath[i];
#       uncompressedPath[cpt-1]='\0';
#     }
#  
#     i++;
#     j=0;
#   }
#  
#   return uncompressedPath;
#  }