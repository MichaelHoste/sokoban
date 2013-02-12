$ ->
  window.banner_position = $('#banner').position().top

  # mouse hover on a picture in the banner to show the won levels of this user
  $('#limited-banner img')
    .mouseenter( ->
      span = $(this).next() # hidden span with won levels informations
      won_levels_ids = $.trim(span.text()).split(',')
      for level_id in won_levels_ids
        level_button = $("#level-#{level_id} span")
        $(level_button).closest('li').addClass('won-selected')
      show_user_infos(span)
    )
    .mouseleave( ->
      $('.levels > li span').closest('li').removeClass('won-selected')
      hide_user_infos()
    )

  show_user_infos = (span) ->
    user_id              = span.attr('data-user-id')
    user_name            = span.attr('data-user-name')
    local_success_count  = span.attr('data-local-success')
    global_success_count = span.attr('data-global-success')

    user_picture = span.prev()
    user_hover = $('#user-hover')

    user_hover.css(
      top:  user_picture.offset().top + 43
      left: user_picture.offset().left - user_hover.width() / 2.0 + user_picture.width() / 2.0 + 6
    )

    user_hover.find('.user-name').html(user_name)
    user_hover.find('.user-stars-pack .num').html(local_success_count)
    user_hover.find('.user-stars-total .num').html(global_success_count)

    user_hover.show()

  hide_user_infos = ->
    $('#user-hover').hide()

  reposition_banner = ->
    scroll_top = $(window).scrollTop()

    # banner on top !
    if scroll_top > window.banner_position
      $('#banner').css('position', 'fixed')
      $('#banner').css('top', '0px')
    # banner on this normal position
    else
      $('#banner').css('position', 'absolute')
      $('#banner').css('top', window.banner_position)

  # update banner with each user score and hidden levels string
  window.update_banner = ->
    console.log("verifier methode")
    pack_name = $('#packs').attr('data-pack-name')
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
  $('#limited-banner').delegate('#add-friend', 'click', ->
    window.facebook_send(window.location.href, 'Can you beat me on that Sokoban level !?')
    return false
  )

  # send new message (clic on a friend on the banner)
  $('#limited-banner img').live('click', ->
    if $(this).attr('data-f_id')
      f_id = $(this).attr('data-f_id')
    else
      f_id = ''

    window.facebook_send(window.location.href, 'Can you beat me on that Sokoban level !?', f_id)
    return false
  )

  # keep the friends banner on top of the page
  reposition_banner()
  $(window).scroll( -> reposition_banner())
