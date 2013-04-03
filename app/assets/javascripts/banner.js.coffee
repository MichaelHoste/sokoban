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

  user_hover.fadeIn()

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
  $('#limited-banner').delegate('img.facebook-friends', 'click', ->
    window.facebook_send_to_feed($(this).attr('data-f_id'))
    return false
  )

  $('#add-one-friend').live('click', ->
    window.facebook_send_invitation_message()
    return false
  )

  $('#add-more-friends').live('click', ->
    window.facebook_send_recursive_app_request()
    return false
  )

  $('#share-on-wall').live('click', ->
    window.facebook_send_to_feed()
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

