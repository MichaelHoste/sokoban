$ ->
  # Refresh scores when click on "more scores" of "friends scores"
  $('#more-friend-score').live('click', ->
    friend_page = parseInt($(this).attr('data-page')) + 1
    global_page = parseInt($('#more-global-score').attr('data-page'))

    window.reload_scores(friend_page, global_page)
  )

  # Refresh scores when click on "more scores" of "global scores"
  $('#more-global-score').live('click', ->
    friend_page = parseInt($('#more-friend-score').attr('data-page'))
    global_page = parseInt($(this).attr('data-page')) + 1

    window.reload_scores(friend_page, global_page)
  )

  $('#scores').delegate('.score-item', 'click', ->
    if $(this).attr('data-is-friend') == 'true'
      window.facebook_send_to_feed($(this).attr('data-f_id'))
    else
      window.facebook_send_invitation_message($(this).attr('data-f_id'))
    return false
  )

  $('#game-won .final-score-item').live('click', ->
    window.facebook_send_to_feed($(this).attr('data-f_id'))
    return false
  )
