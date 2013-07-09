$ ->
  $('#menus .rules-menu').on('click', ->
    window.colorbox_welcome()
  )

  $('#menus .fb-login, #menus .ranking-menu, #menus .logout').on('click', ->
    location.assign($(this).find('a').attr('href'))
  )

  # Show logout only if not on facebook canvas
  # http://blog.blakesimpson.co.uk/read/22-detect-if-page-is-within-facebook-iframe-or-not-javascript
  if window.name == ''
    $('#menus .logout').show()

  # initialize and change theme
  window.theme = "classic"
