$ ->
    
  $("#menus .fb_login").on('click', ->
    window.colorbox_facebook()
  )

  $("#menus .fb_logout").on('click', ->
    location.assign('/logout')
  )
