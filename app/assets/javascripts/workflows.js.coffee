$ ->
  # Click on 'next' on "welcome"
  $('#welcome .button-next').on('click', ->
    window.colorbox_controls()
    start_animation(1000)
    false
  )
  
  # Click on 'next' on "controls"
  $('#controls .button-next').on('click', ->
    window.colorbox_rules()
    false
  )
  
  # Click on 'next' on "rules"
  $('#rules .button-next').on('click', ->
    if $('#menus .fb_login').length
      window.colorbox_facebook()
    else
      $.fn.colorbox.close()
    false
  )
  
  # Hover the next-level image
  $('#next-level-thumb-canvas, #next-level .next-level-next').on('click', ->
    # change the level (the '.is-selected' level is chosen)
    $.fn.colorbox.close()
    
    button = $('#levels .is-selected')
    next_button = button.next('li')
    button.removeClass('is-selected')
    next_button.addClass('is-selected')

    window.change_level()
    
    # change the url and save related state (pack and level)
    window.push_this_state()

    # update banner
    pack_name = $('#packs > li').text()
    $.get('/banner', {pack_name: pack_name}).success((data, status, xhr) ->
      # update each hidden span with successfully completed levels string
      $.each(data, (key, value) ->
        id = key.split('_')[1]
        user_span = $("#limited-banner span[data-user-id=#{id}]")
        if user_span.length
          user_span.html(value)
      )
    )

    false
  )

  pusher_move = (dir) ->
    $('#controls .pusher .middle img').attr('src', '/images/themes/classic/floor64.png')
    $("#controls .pusher .#{dir} img").attr('src', '/images/themes/classic/pusher64.png')
    $("#controls .keyboard img").attr("src", "/assets/arrow_keys_#{dir}.png")

  pusher_center = ->
    for dir in ['up', 'down', 'left', 'right']
      $("#controls .pusher .#{dir} img").attr('src', '/images/themes/classic/floor64.png')
      
    $("#controls .pusher .middle img").attr('src', '/images/themes/classic/pusher64.png')
    $("#controls .keyboard img").attr("src", "/assets/arrow_keys.png")
  
  # controls animation : pusher up, down, left, right
  start_animation = (delay) ->
    setTimeout(( -> pusher_move('up')), delay)
    setTimeout(( -> pusher_center()), 2*delay)
    setTimeout(( -> pusher_move('down')), 3*delay)
    setTimeout(( -> pusher_center()), 4*delay)
    setTimeout(( -> pusher_move('left')), 5*delay)
    setTimeout(( -> pusher_center()), 6*delay)
    setTimeout(( -> pusher_move('right')), 7*delay)
    setTimeout(( -> pusher_center()), 8*delay)
    setTimeout(( -> start_animation(delay)), 8*delay)