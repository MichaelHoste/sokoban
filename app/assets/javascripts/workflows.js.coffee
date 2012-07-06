$ ->
  # click on 'how to play'
  $('#welcome .button-continue').on('click', ->
    window.colorbox_rules()
    false
  )
