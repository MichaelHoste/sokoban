redirect_to_facebook_login_if_not_logged = ->
  if $('#menus .fb_login').length
    window.colorbox_facebook()
  else
    $.fn.colorbox.close()

reload_colorbox_random_level = ->
  $(document).bind('cbox_closed', ->
    window.colorbox_random_level()
    $(document).unbind('cbox_closed')
  )
  window.hide_all_tipsy()
  $.fn.colorbox.close()

bind_invite_friends = ->
  # Click on 'later' on 'invite-friends'
  $('#invite-friends .button-next').on('click', ->
    window.hide_all_tipsy()
    $.fn.colorbox.close()
    false
  )

  # Click on 'later' on 'donation-page'
  $('#donation-page .button-next').on('click', ->
    window.hide_all_tipsy()
    $.fn.colorbox.close()
  )

  # Click on a friend thumb
  $('#invite-friends .friends img').on('click', ->
    window.facebook_send_app_request($(this).attr('data-f_id'), [])
  )

  # Click on the big invite button
  $('#invite-friends .friend-button').on('click', ->
    window.facebook_send_recursive_app_request()
  )

bind_donation_page = ->
  $('#donation-page .wall').on('click', ->
    window.facebook_send_to_feed($(this).attr('data-f_id'))
    false
  )

  $('#donation-page .all').on('click', ->
    window.facebook_send_recursive_app_request()
    false
  )

  $('#donation-page .some').on('click', ->
    window.facebook_send_app_request()
    false
  )

  $('#donation-page .custom').on('click', ->
    window.facebook_send_custom_invitation_message()
    false
  )

# 1/3 facebook fan page or (1 times on 4) twitter (deactivated if facebook page is liked)
# 1/3 invite friends (if user don't have a 7 days derogation)
  # -> 4 different ways of inviting friends
# 1/3 random level
window.random_social_popup = ->
  random = Math.floor((Math.random()*3)+1) # number between 1 and 3
  logged = $('#menus .fb_logged').length

  if random == 1
    if (logged and $('#menus .fb_logged').attr('data-like-facebook-page') == 'false') or !logged
      random2 = Math.floor((Math.random()*3)+1) # number between 1 and 4
      if random2 == 1
        window.colorbox_twitter_page()
      else
        window.colorbox_facebook_page()
  else if random == 2
    if logged and $('#menus .fb_logged').attr('data-display-invite-popup') == 'true'
      random2 = Math.floor((Math.random()*5)+1) # number between 1 and 4
      if random2 == 1
        window.colorbox_invite_friends()
      else if random2 == 2
        window.facebook_send_app_request_to_challenge_users()
      else if random2 == 3
        window.facebook_send_app_request()
      else if random2 == 4
        window.colorbox_donation()
      else
        window.facebook_send_custom_invitation_message()
  else
    window.colorbox_random_level()

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
    if $("#menus .fb_logged").length and $("#menus .fb_logged").attr('data-like-facebook-page') == 'false'
      window.colorbox_facebook_page()
    else
      redirect_to_facebook_login_if_not_logged()
    false
  )

  # Click on 'next' on "facebook-page"
  $('#facebook-page .button-next').on('click', ->
    window.update_like_facebook_page_value()
    redirect_to_facebook_login_if_not_logged()
    false
  )

  # Click on 'next' on "twitter-page"
  $('#twitter-page .button-next').on('click', ->
    $.fn.colorbox.close()
    false
  )

  # Click on the next level
  $('#next-level-canvas, .game-action-next').on('click', ->
    # change the level (the '.is-selected' level is chosen)
    window.hide_all_tipsy()
    $.fn.colorbox.close()

    button = $('#levels .is-selected')

    next_button = button.next('li')
    if not next_button.length
      next_button = button.parent().find('li:first')

    button.removeClass('is-selected')
    next_button.addClass('is-selected')

    window.change_level()

    # change the url and save related state (pack and level)
    window.push_this_state()

    setTimeout(random_social_popup, 1000)
    false
  )

  # Click on retry level
  $('#this-level-canvas, .game-action-retry').on('click', ->
    # change the level (the '.is-selected' level is chosen)
    window.hide_all_tipsy()
    $.fn.colorbox.close()

    window.change_level()
    false
  )

  $('.game-action-challenge').on('click', ->
    reload_colorbox_random_level()
    false
  )

  $('#random-level-canvas').on('click', ->
    level_name = $(this).parent().attr('data-level-slug')
    pack_name  = $(this).parent().attr('data-pack-slug')
    location.assign("/packs/#{pack_name}/levels/#{level_name}")
  )

  $('#random-level .reload-button').on('click', ->
    reload_colorbox_random_level()
    false
  )

  $('#random-level .later-button').on('click', ->
    window.hide_all_tipsy()
    $.fn.colorbox.close()
    false
  )

  bind_invite_friends()
  bind_donation_page()

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
