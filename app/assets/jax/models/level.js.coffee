###
   
###

Jax.getGlobal()['Level'] = Jax.Model.create
  
  # Constructor
  after_initialize: ->
    @objects = [] # list of objects to be displayed

    # load selected level
    pack_name = $("#packs > li").text()
    level_name = $('#levels').find('.is-selected .level-id').attr('title')
    
    @level_core = new LevelCore()
    @level_core.create_from_database(pack_name, level_name)
    
    # display level
    @display_level()

  ###
    Create (create objects) or refresh (change textures) the level
  ###
  display_level: ->
    for m in [0..@level_core.rows_number-1]
      for n in [0..@level_core.cols_number-1]
        @display_position(m, n)
  
  ###
    display a specific position of the level. If the object doesn't exist,
    create it, and if the object exists, refresh the texture
    @param m number of the row to create/refresh
    @param n number of the column to create/refresh
  ###
  display_position: (m, n) ->
    cols_number = @level_core.cols_number
    rows_number = @level_core.rows_number
    
    type = @level_core.read_pos(m, n)
        
    # create object
    if type != ' ' and not @objects[cols_number*m + n]
      object = Square.find 'actual'
      @objects[cols_number*m + n] = object
      
      start_col = -cols_number/2.0 + 0.5
      start_row = rows_number/2.0 - 0.5
      
      d_height = rows_number / (2*0.414213563) * 1.1 # 0.41 = tan(22.5°), *0.9 is to create a border
      d_width = cols_number / (2*0.414213563/14*20) # 0.41 = tan(22.5°), 14*20 is the ration height/width
      d = d_height if d_height > d_width
      d = d_width  if d_width  > d_height
            
      object.camera.setPosition [start_col + n, start_row - m, -d]
    else if type != ' '
      object = @objects[cols_number*m + n]
        
    # refresh material
    if type == 's'
      object.mesh.material = 'floor'
    else if type == '#'
      object.mesh.material = 'wall'
    else if type == '$'
      object.mesh.material = 'box'
    else if type == '*'
      object.mesh.material = 'boxgoal'
    else if type == '.'
      object.mesh.material = 'goal'
    else if type == '@'
      object.mesh.material = 'pusher'
    else if type == '+'
      object.mesh.material = 'pushergoal'
      
  # refresh the level textures depending on the new position of the pusher
  # * refresh pusher position and 4 neighbours (u,d,l,r) if forward move
  # * refresh pusher position and 8 neighbours (u,d,l,r,uu,dd,ll,rr) if reverse move (undo)
  refresh: (reverse = 0) ->
    # take the new pusher position and its 4 direct neighbours
    pusher_m = @level_core.pusher_pos_m
    pusher_n = @level_core.pusher_pos_n

    positions =
      [
        [pusher_m,   pusher_n]
        [pusher_m+1, pusher_n]
        [pusher_m-1, pusher_n]
        [pusher_m,   pusher_n+1]
        [pusher_m,   pusher_n-1]
      ]
    
    # if deleted move, refresh its 8 neighbours
    if reverse
      positions.push( [pusher_m+2, pusher_n] )
      positions.push( [pusher_m-2, pusher_n] )
      positions.push( [pusher_m,   pusher_n+2] )
      positions.push( [pusher_m,   pusher_n-2] )
 
    # visually refresh these positions
    for position in positions
      if @read_pos(position[0], position[1]) != 'E'
        @display_position(position[0], position[1])
  
  # Render every squares of the level (the level itself is just a mesh container)
  render: (context, options) ->
    if @objects
      if !Jax.Model.__instances[@__unique_id]
        Jax.Model.__instances[@__unique_id] = @
      options = Jax.Util.normalizeOptions(options, { model_index: @__unique_id });
      context.pushMatrix( =>
        #context.multModelMatrix(this.camera.getTransformationMatrix())
        for i in [0..@cols_number()*@rows_number()-1]
          if @objects[i]
            @objects[i].render(context, options)
      )
        
  unload: (world) ->
    # delete each square of the level
    for i in [0..@level_core.cols_number*@level_core.rows_number-1]
      if @objects[i]
        @objects[i].dispose()
        delete @objects[i]
    delete @objects
    
    # delete associated level_core
    delete @level_core.grid
    delete @level_core    
    
    # remove level from the world
    world.removeObject @__unique_id
      
  cols_number: ->
    @level_core.cols_number

  rows_number: ->
    @level_core.rows_number

  read_pos: (m, n) ->
    @level_core.read_pos(m, n)
      
  write_pos: (m, n, letter) ->
    @level_core.write_pos(m, n, letter)
    
  pusher_can_move: (direction) ->
    @level_core.pusher_can_move(direction)

  move: (direction) ->
    @level_core.move(direction)
  
  delete_last_move: (path) ->
    @level_core.delete_last_move(path)
  
  is_won: ->
    @level_core.is_won()
      
  print: ->
    @level_core.print()
  