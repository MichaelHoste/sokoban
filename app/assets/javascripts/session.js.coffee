$ ->
  # link of the big facebook button
  $('#session .session-button').click( ->
    location.assign($('.session-connect a').attr('href'))
  )