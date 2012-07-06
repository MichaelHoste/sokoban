$ ->
  # click on 'how to play'
  $('#welcome .button-how-to-play').on('click', ->
    window.colorbox_rules()
    false
  )
  
  # click on 'play'
  $('#welcome .button-play').on('click', ->
    window.colorbox_facebook()
    false
  )