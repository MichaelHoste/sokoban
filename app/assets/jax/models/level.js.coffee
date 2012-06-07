###
  2D or 3D level display methods
###

Jax.getGlobal()['Level'] = Jax.Model.create
  
  # Constructor
  after_initialize: ->
    @objects = [] # list of objects to be displayed
    @level_core = new LevelCore()
    
  create_3d: (pack_name, level_name) ->
    @display_type = '3D'
    @level_core.create_from_database(pack_name, level_name)
    @display_level()
    
  create_2d: (pack_name, level_name) ->
    @display_type = '2D'
    @level_core.create_from_database(pack_name, level_name)
    @context_2d = @compute_2d_context()
    if window.raphael_div
      window.raphael_div.clear()
    else      
      window.raphael_div = Raphael('raphael', @context_2d.width, @context_2d.height)
    @display_level()
    
  switch_to_3d: ->    
    # delete 2D objects
    for i in [0..@level_core.cols_number*@level_core.rows_number-1]
      if @objects[i]
        @objects[i].remove()
        delete @objects[i]
        
    # display 3D level
    @display_type = '3D'
    @display_level()
    
  switch_to_2d: ->    
    # delete 3D objects
    for i in [0..@level_core.cols_number*@level_core.rows_number-1]
      if @objects[i]
        @objects[i].dispose()
        delete @objects[i]
    
    # display 2D level    
    @display_type = '2D'
    @context_2d = @compute_2d_context()
    if window.raphael_div
      window.raphael_div.clear()
    else      
      window.raphael_div = Raphael('raphael', @context_2d.width, @context_2d.height)
    @display_level()
    
  ###
    Compute width, height and box_size for 2D Display
  ###
  compute_2d_context: ->
    context.width  = $('#raphael').width()
    context.height = $('#raphael').height()
    
    size_width  = context.width  / (@cols_number() + 2.0)
    size_height = context.height / (@rows_number() + 2.0)
    
    context.box_size = Math.min(size_width, size_height)
    return context

  ###
    Create (create objects) or refresh the level
  ###
  display_level: ->
    # 3d display    
    if @display_type == '3D'
      for m in [0..@level_core.rows_number-1]
        for n in [0..@level_core.cols_number-1]
          @display_position_3d(m, n)
    
    # 2d display
    else if @display_type == '2D'
      box_size = @context_2d.box_size
      start =
        x: Math.round((@context_2d.width - box_size*@cols_number()) / 2.0)
        y: Math.round((@context_2d.height - box_size*@rows_number()) / 2.0)
      for m in [0..@level_core.rows_number-1]
        start.x = Math.round((@context_2d.width - box_size*@cols_number()) / 2.0)
        for n in [0..@level_core.cols_number-1]
          @display_position_2d(m, n, start)
          start.x = Math.round(start.x + box_size)
        start.y = Math.round(start.y + box_size)
  
  ###
    display a specific position of the level in 3D. If the object doesn't exist,
    create it, and if the object exists, refresh the texture
    @param m number of the row to create/refresh
    @param n number of the column to create/refresh
  ###
  display_position_3d: (m, n) ->
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
      
  ###
    display a specific position of the level. If the object doesn't exist,
    create it, and if the object exists, edit the texture
    @param m number of the row to create/refresh
    @param n number of the column to create/refresh
    @param start pixel position where to start drawing the cell
  ###
  display_position_2d: (m, n, start) ->
    cols_number = @level_core.cols_number
    rows_number = @level_core.rows_number
    size = @context_2d.box_size
  
    type = @level_core.read_pos(m, n)

    # create object
    if type != ' ' and not @objects[cols_number*m + n]
      object = window.raphael_div.image('/images/box64.png', start.x, start.y, size, size)
      @objects[cols_number*m + n] = object
    else if type != ' '
      object = @objects[cols_number*m + n]
    
    # refresh material
    if type == 's' and object.attrs.src != '/images/floor64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/floor64.png', start.x, start.y, size, size)
    else if type == '#' and object.attrs.src != '/images/wall64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/wall64.png', start.x, start.y, size, size)
    else if type == '$' and object.attrs.src != '/images/box64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/box64.png', start.x, start.y, size, size)
    else if type == '*' and object.attrs.src != '/images/boxgoal64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/boxgoal64.png', start.x, start.y, size, size)
    else if type == '.' and object.attrs.src != '/images/goal64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/goal64.png', start.x, start.y, size, size)
    else if type == '@' and object.attrs.src != '/images/pusher64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/pusher64.png', start.x, start.y, size, size)
    else if type == '+' and object.attrs.src != '/images/pushergoal64.png'
      object.remove()
      @objects[cols_number*m + n] = object = window.raphael_div.image('/images/pushergoal64.png', start.x, start.y, size, size)
        
  # Render every squares of the level (the level itself is just a mesh container)
  # ONLY IF IN 3D MODE !
  render: (context, options) ->
    if @display_type == '3D' and @objects
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
  