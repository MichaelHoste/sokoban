$ ->
  $('#menus .fb_logout').on('click', ->
    location.assign('/logout')
  )

  $('#menus .fb_login').on('click', ->
    location.assign('/connect_facebook')
  )

  $('#menus .rules-menu').on('click', ->
    window.colorbox_welcome()
  )

  $('#menus .ranking-menu').on('click', ->
    location.assign($(this).find('a').attr('href'))
  )

  # initialize and change theme
  window.theme = "classic"
