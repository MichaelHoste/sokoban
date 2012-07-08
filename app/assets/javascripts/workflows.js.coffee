$ ->
  # click on 'how to play'
  $('#welcome .button-continue').on('click', ->
    window.colorbox_rules()
    false
  )

  pusher_move = (dir) ->
    $('#controls .pusher .middle img').attr('src', '/images/floor64.png')
    $("#controls .pusher .#{dir} img").attr('src', '/images/pusher64.png')

  pusher_center = ->
    for dir in ['up', 'down', 'left', 'right']
      $("#controls .pusher .#{dir} img").attr('src', '/images/floor64.png')
      
    $("#controls .pusher .middle img").attr('src', '/images/pusher64.png')