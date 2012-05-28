$ ->
  # link of the big facebook button
  $('#session .session-button').on('click', ->
    location.assign($('.session-connect a').attr('href'))
  )