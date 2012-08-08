$ ->
  window.banner_position = $('#banner').position().top
  
  # mouse hover on a picture in the banner to show the won levels of this user
  $('#limited-banner img')
    .mouseenter( ->
      #$(this).transition({ scale: 1.5 })
      span = $(this).next() # hidden span with won levels informations
      won_levels_ids = $.trim(span.text()).split(',')
      for level_id in won_levels_ids
        level_button = $("#level-#{level_id}")
        $(level_button).addClass('won-by-friend')
    )
    .mouseleave( ->
      #$(this).transition({ scale: 1.0 })
      $('.levels > li').removeClass('won-by-friend')
    )
  
  # keep the friends banner on top of the page
  $(window).scroll( ->
    scroll_top = $(window).scrollTop()
    
    # banner on top !
    if scroll_top > window.banner_position
      $('#banner').css('position', 'fixed')
      $('#banner').css('top', '0px')
    # banner on this normal position
    else
      $('#banner').css('position', 'absolute')
      $('#banner').css('top', window.banner_position)
  )

  # update banner with each user score and hidden levels string  
  window.update_banner = ->
    pack_name = $('#packs > li').text()
    $.get('/banner', {pack_name: pack_name}).success((data, status, xhr) ->
      # update each hidden span with successfully completed levels string
      $.each(data['success'], (key, value) ->
        user_span = $("#limited-banner span[data-user-id=#{key}]")
        if user_span.length
          user_span.html(value)
      )
          
      # update each image title with name and new count
      $.each(data['count'], (key, value) ->
        user_span = $("#limited-banner span[data-user-id=#{key}]")
        if user_span.length
          user_span.prev().attr('original-title', value)
      )
    )
    
  # send new message (invite friends)
  $('#add-friend').on('click', ->
    window.facebook_send(window.location.href, "Can you beat me on that Sokoban level !?")
    return false
  )