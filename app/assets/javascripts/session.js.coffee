$ ->
  # link of the big facebook button
  $("#session-button").click( ->
    location.assign($(".session-connect a").attr('href'))
  )