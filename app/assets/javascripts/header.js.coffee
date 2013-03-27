$ ->
  $('#menus .fb_logout').on('click', ->
    location.assign('/logout')
  )

  $('#menus .fb_login').on('click', ->
    location.assign('/auth/facebook')
  )

  $('#menus .rules-menu').on('click', ->
    window.colorbox_welcome()
  )

  # initialize and change theme
  window.theme = "classic"

#  $('#theme').on('change', ->
#    window.theme = $(this).val()
#  )


