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
  if scroll_top > window.banner_position + 9
    $('#banner').css('position', 'fixed')
    $('#banner').css('top', '-9px')
  # banner on this normal position
  else
    $('#banner').css('position', 'absolute')
    $('#banner').css('top', window.banner_position )

# update banner with each user score and hidden levels string
window.update_banner = ->
  pack_name = $('#packs').attr('data-pack-name')
  $.get('/banner', {pack_name: pack_name}).success((data, status, xhr) ->
    $('#limited-banner').html($(data).find('#limited-banner').html())
  )

bind_banner = ->
  # send new message (invite friends)
  $('#add-one-friend').live('click', ->
    window.facebook_send(window.location.href, 'Can you solve this Sokoban level !?')
    return false
  )

  # send app requests (https://developers.facebook.com/docs/tutorials/canvas-games/requests/)
  $('#add-more-friends').live('click', ->
    total_success = $('#user-infos').attr('data-global-success')
    if total_success != '' and parseInt(total_success) <= 5
      message = "Can you solve as many Sokoban levels as me?"
    else
      message = "I already solved #{total_success} Sokoban levels, can you beat me?"
    window.facebook_app_request("Play Sokoban with me!", message, {})
    return false
  )

  # send new message (clic on a friend on the banner)
  $('#limited-banner').delegate('img.facebook-friends', 'click', ->
    if $(this).attr('data-f_id')
      f_id = $(this).attr('data-f_id')
    else
      f_id = ''

    window.facebook_send(window.location.href, 'Can solve this Sokoban level !?', f_id)
    return false
  )

  # mouse hover on a picture in the banner to show the won levels of this user
  $('#limited-banner').delegate('img', 'mouseenter', ->
    span = $(this).next() # hidden span with won levels informations
    won_levels_list = $.trim(span.text()).split(',')
    for level_id in won_levels_list
      level_button = $("#level-#{level_id} span")
      $(level_button).closest('li').addClass('won-selected')
    show_user_infos(span)
  )

  $('#limited-banner').delegate('img', 'mouseleave', ->
    $('.levels > li span').closest('li').removeClass('won-selected')
    hide_user_infos()
  )

$ ->
  window.banner_position = $('#banner').position().top
  bind_banner()

  # keep the friends banner on top of the page
  reposition_banner()
  $(window).scroll( -> reposition_banner())

