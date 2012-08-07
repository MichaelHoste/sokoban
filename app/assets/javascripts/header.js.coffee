$ ->
  # click on "login with facebook" icon
  $('#menus .fb_login').on('click', ->
    location.assign('/auth/facebook')
  )
  
  # hover on "login with facebook" or "name of user" icon
  $('#menus .fb_login, #menus .fb_logout').on('mouseenter', ->
    if $('#menus .fb_login').length
      pos = $('#menus .picture.fb_login').position()
      height = $('#menus .picture.fb_login').height() + 7
    else if $('#menus .fb_logout').length
      pos = $('#menus .picture.fb_logout').position()
      height = $('#menus .picture.fb_logout').height() + 7
    
    login_hover = $('#login-hover')
    login_hover.css('left', pos.left)
    login_hover.css('top' , pos.top + height)
    login_hover.css('z-index', 201)
    login_hover.clearQueue().transition({ opacity: 1.0 })
  )
  
  $('#menus .fb_login, #menus .fb_logout').on('mouseleave', ->
    $('#login-hover').clearQueue().transition({ opacity: 0.0 })
  )

  $('#menus .fb_logout').on('click', ->
    location.assign('/logout')
  )

  $('#menus .challenges-menu').on('click', ->
    location.assign('/scores')
  )

  $('#menus .packs-menu').on('click', ->
    location.assign('/packs')
  )
  
  $('#menus .rules-menu').on('click', ->
    window.colorbox_welcome()
  )
  
  # initialize and change theme
  window.old_theme = $('#theme').val()
  window.theme = window.old_theme
  
  $('#theme').on('change', ->
    window.theme = $(this).val()
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
    $(this).transition({opacity:0.0})
  )
  
  # animation on like divs
  animate_like_divs = ->
    $('#likes .fb-like').clearQueue().transition({ opacity:0.93 }).delay(300).transition({ opacity:0.0 }).delay(200, ->
      $('#likes .twitter-like').clearQueue().transition({ opacity:0.93 }).delay(300).transition({ opacity:0.0 }).delay(200, ->
        $('#likes .gplus-like').clearQueue().transition({ opacity:0.93 }).delay(300).transition({ opacity:0.0 }).delay(200, ->
          setTimeout(animate_like_divs, 120000)  
        )
      )
    )
    
  setTimeout(animate_like_divs, 10000)