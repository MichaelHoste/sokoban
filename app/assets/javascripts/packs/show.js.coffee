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
    
    # show scores related to the new level
    pack_name = $('#packs > li').text()
    level_name = $('#levels').find('.is-selected').attr('data-level-name')
    $.get('/scores',
      pack_id: pack_name
      level_id: level_name
    )
    .success((data, status, xhr) =>
      $('#scores').html(data)
      $('#scores').effect('highlight')
    )
  )
  
  # Level on level => create and position thumb
  $('#levels li').live('mouseenter', ->
    level_thumb = $('.level-thumb')
    level_thumb.stop(true, true)
    clearTimeout(window.time_out_thumb)
    level_thumb.show()
    
    # compute and set position of the level thumb
    content_offset = $('#limited-content').offset()
    button_offset = $(this).offset()
    levels_offset = $('#levels').offset()  
    thumb_offset =
      left: $('.level-thumb').offset().left
      top: button_offset.top - level_thumb.height()/2 + $(this).height()/2 + 5
    
    # top and bottom position of the thumb cannot be out of the menu
    if thumb_offset.top < levels_offset.top
      thumb_offset.top = levels_offset.top
    else if thumb_offset.top > levels_offset.top + $('#levels').height() - level_thumb.height()
      thumb_offset.top = levels_offset.top + $('#levels').height() - level_thumb.height()
          
    level_thumb.offset(thumb_offset)
    level_thumb.animate({ left: '259px' }, 200)
    
    # create thumb image
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
    # hide level thumb
    level_thumb = $('.level-thumb')
    
    my_method = (level_thumb) ->
      level_thumb.animate({ left: '50px' }, 200, ->
        $(this).hide()
      )
      
    window.time_out_thumb = setTimeout((-> my_method(level_thumb)), 1000)
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
  