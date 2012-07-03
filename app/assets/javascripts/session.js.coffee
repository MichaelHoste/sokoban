$ ->
  # link of the big facebook button
  $('#session .session-button').on('click', ->
    location.assign($('.session-connect a').attr('href'))
  )
  
  # personnalized close button "don't want to connect"
  $('#session .session-regular-link a').on('click', ->
    $.fn.colorbox.close()
    return false
  )