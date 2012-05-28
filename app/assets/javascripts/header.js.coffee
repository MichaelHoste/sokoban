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