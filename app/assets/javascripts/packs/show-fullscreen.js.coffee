$ ->
  window.level_full_screen = false

  $('#game').delegate('.fullscreen', 'click', ->
    if not window.level_full_screen
      window.level_full_screen = true
    else
      window.level_full_screen = false

    $('#game').fullScreen(window.level_full_screen)
  )

  $(document).bind('fullscreenchange', ->
    if window.level_full_screen
      $('#game .large-shad').hide()
    else
      $('#game .large-shad').show()
  )
