$ ->
  # Initialize webgl and load selected level
  window.context = new Jax.Context('webgl')
  window.context.redirectTo('level/index')
  
  # Scroll the left menu to the selected level
  level_button = $('#levels .is-selected')
  $('#levels').scrollTo(level_button, 1000, { easing:'swing', offset: -10 } )
  
  # Click on level (on packs/show)
  $('#levels li').live('click', ->
    $(this).parent().find(".is-selected").removeClass("is-selected")
    $(this).addClass("is-selected")

    # FIXME window.context.redirectTo must be sufficient and faster !
    # but it seems to have a memory leak somewhere (Jax or me ?)
    window.context.dispose()
    window.context = new Jax.Context('webgl')
    window.context.redirectTo("level/index")
  )
  
  # Level on level => create and position thumb
  $('#levels li').live('mouseenter', ->
    level_thumb = $('.level-thumb')
    level_thumb.show()
    
    level_li = $(this)
    grid   = level_li.attr('data-level-grid')
    width  = level_li.attr('data-level-width')
    height = level_li.attr('data-level-height')
    
    level_thumb.attr('data-level-grid', grid)
    level_thumb.attr('data-level-width', width)
    level_thumb.attr('data-level-height', height)
    
    window.level_thumb()
  )
  
  $('#levels li').live('mouseleave', ->
    level_thumb = $('.level-thumb')
    level_thumb.hide()
  )
  
  # deadlock div
  $('#deadlock').live('mouseenter', ->
    $(this).clearQueue()
    $(this).transition({opacity:0.93})
  )
  
  $('#deadlock').live('mouseleave', ->
    $(this).clearQueue()
    $(this).transition({opacity:0.2})
  )
  