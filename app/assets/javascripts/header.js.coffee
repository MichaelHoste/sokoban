$ ->
    
  $('#menus .fb_login').on('click', ->
    window.colorbox_facebook()
  )

  $('#menus .fb_logout').on('click', ->
    location.assign('/logout')
  )

  $('#menus .packs-menu').on('click', ->
    location.assign('/packs')
  )
  
  $('#menus .scores-menu').on('click', ->
    location.assign('/scores')
  )
  
  $('#menus .rules-menu').on('click', ->
    location.assign('/rules')
  )
  
  # Click on 2D switch
  $('#menus .switch-2d').live('click', ->
    if not $(this).hasClass('is-selected')
      $(this).addClass('is-selected')
      $('#menus .switch-3d').removeClass('is-selected')
      window.context.redirectTo("level/index")
      $('#webgl').hide()
      $('#raphael').show()
  )
  
  # Click on 3D switch
  $('#menus .switch-3d').live('click', ->
    if not $(this).hasClass('is-selected')
      $(this).addClass('is-selected')
      $('#menus .switch-2d').removeClass('is-selected')
      window.context.redirectTo("level/index")
      $('#raphael').hide()
      $('#webgl').show()
  )
  
  # likes div
  $('#likes > div').live('mouseenter', ->
    $(this).clearQueue()
    $(this).transition({opacity:0.93})
  )
  
  $('#likes > div').live('mouseleave', ->
    $(this).clearQueue()
    $(this).transition({opacity:0.1})
  )
  
  # animation on like divs
  animate_like_divs = ->
    $('#likes .fb-like').clearQueue().transition({ opacity:0.93 }).delay(300).transition({ opacity:0.1 }).delay(200, ->
      $('#likes .twitter-like').clearQueue().transition({ opacity:0.93 }).delay(300).transition({ opacity:0.1 }).delay(200, ->
        $('#likes .gplus-like').clearQueue().transition({ opacity:0.93 }).delay(300).transition({ opacity:0.1 }).delay(200, ->
          setTimeout(animate_like_divs, 120000)  
        )
      )
    )
    
  setTimeout(animate_like_divs, 10000)