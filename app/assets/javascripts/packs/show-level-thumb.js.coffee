$ ->
  # Level on level => create and position thumb
  $('#levels li').live('mouseenter', ->
    level_thumb = $('.level-thumb')
    level_thumb.show()

    # compute and set position of the level thumb
    content_offset = $('#limited-content').offset()
    button_offset = $(this).offset()
    levels_offset = $('#levels').offset()
    thumb_offset =
      left: button_offset.left + 65
      top: button_offset.top

    level_thumb.offset(thumb_offset)

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
    $('.level-thumb').hide()
  )
