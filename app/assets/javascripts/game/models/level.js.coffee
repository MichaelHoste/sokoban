###
  Level display methods
###

class window.Level

  # Constructor
  constructor: ->
    @objects = [] # list of objects to be displayed
    @level_core = new LevelCore()

  create: (pack_name, level_name, line = "", width = 0, height = 0, canvas_id = "raphael") ->
    $("##{canvas_id} svg").remove()

    if line != ""
      @level_core.create_from_line(line, parseInt(width), parseInt(height))
    else
      @level_core.create_from_database(pack_name, level_name)

    @context = @compute_context(canvas_id)

    if @context.canvas
      @context.canvas.clear()
    else
      @context.canvas = Raphael(canvas_id, @context.width, @context.height)

    @display_level()

  ###
    Compute width, height and box_size
  ###
  compute_context: (canvas_id) ->
    context = {}
    context.canvas_id = canvas_id
    context.canvas = null

    context.width  = $("##{canvas_id}").width()
    context.height = $("##{canvas_id}").height()

    size_width  = Math.floor(context.width  / (@cols_number() + 2.0))
    size_height = Math.floor(context.height / (@rows_number() + 2.0))

    context.box_size = Math.min(size_width, size_height)

    context.highlighted_rects = []

    return context

  ###
    Create (create objects) or refresh the level
  ###
  display_level: ->
    box_size = @context.box_size
    start =
      x: 0 # will be overriden
      y: (@context.height - box_size*@rows_number()) / 2.0
    for m in [0..@level_core.rows_number-1]
      start.x = (@context.width - box_size*@cols_number()) / 2.0
      for n in [0..@level_core.cols_number-1]
        @display_position(m, n, start)
        start.x = start.x + box_size
      start.y = start.y + box_size

  ###
    Highlight positions (stay highlighted until new call)
    @param positions array of deadlocked positions [{m, n}, ...]
  ###
  highlight: (positions) ->
    # delete old highlighted rects
    for highlighted_rect in @context.highlighted_rects
      highlighted_rect.rect.remove()
    delete @context.highlighted_rects
    @context.highlighted_rects = []

    # highlight each positions
    for pos in positions
      # get pos and size of the square of that position to draw a rect on it
      object = @objects[@level_core.cols_number*pos.m + pos.n]
      size = object.attrs.height
      x = object.attrs.x
      y = object.attrs.y

      # create highlight rect and add it to the list of highlighted rects
      @context.highlighted_rects.push(
        pos: pos
        rect: @context.canvas.rect(x, y, size, size).attr({ fill: '#2d5a8b', stroke: "none", opacity: .5 })
      )

  ###
    display a specific position of the level. If the object doesn't exist,
    create it, and if the object exists, edit the texture
    @param m number of the row to create/refresh
    @param n number of the column to create/refresh
    @param start pixel position where to start drawing the cell
  ###
  display_position: (m, n, start) ->
    cols_number = @level_core.cols_number
    rows_number = @level_core.rows_number
    size = @context.box_size

    type = @level_core.read_pos(m, n)

    # create object
    if type != ' ' and not @objects[cols_number*m + n]
      object = @context.canvas.image('/assets/themes/classic/wall64.png', Math.ceil(start.x), Math.ceil(start.y), size, size)
      @objects[cols_number*m + n] = object
    else if type != ' '
      object = @objects[cols_number*m + n]

    # refresh material
    @refresh(object, type, 's', 'floor')
    @refresh(object, type, '#', 'wall')
    @refresh(object, type, '$', 'box')
    @refresh(object, type, '*', 'boxgoal')
    @refresh(object, type, '.', 'goal')
    @refresh(object, type, '@', 'pusher')
    @refresh(object, type, '+', 'pushergoal')

  refresh: (object, type, letter, texture) ->
    if type == letter and object.attr('src') != "/assets/themes/#{window.theme}/#{texture}64.png"
      object.attr('src', "/assets/themes/#{window.theme}/#{texture}64.png")

#  unload: ->
#    # delete each square of the level
#    for i in [0..@level_core.cols_number*@level_core.rows_number-1]
#      if @objects[i]
#        @objects[i].dispose()
#        delete @objects[i]
#    delete @objects
#
#    # delete associated level_core
#    delete @level_core.grid
#    delete @level_core

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

  pusher_pos: ->
    { m: @level_core.pusher_pos_m, n: @level_core.pusher_pos_n }

  move: (direction) ->
    @level_core.move(direction)

  delete_last_move: (path) ->
    @level_core.delete_last_move(path)

  is_won: ->
    @level_core.is_won()

  print: ->
    @level_core.print()

