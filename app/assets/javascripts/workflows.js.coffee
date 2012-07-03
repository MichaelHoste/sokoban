$ ->
  # click on 'how to play'
  $('#welcome .button-how-to-play a').on('click', ->
    window.colorbox_rules()
    false
  )
  
  # click on 'play'
  $('#welcome .button-play a').on('click', ->
    false
  )