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