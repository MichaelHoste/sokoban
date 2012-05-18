$ ->
  $("#menus .fb_login").on('click', ->
    $.colorbox({href:'/login', top:'190px', height:'260px', width:'500px'})
  )

  $("#menus .fb_logout").on('click', ->
    location.assign('/logout')
  )
