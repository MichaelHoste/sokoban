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
    if f_id = $(this).attr('data-f_id') != ''
      window.facebook_send(window.location.href, 'Can you beat me on that Sokoban level !?', f_id)
    return false
  )

  $('#game-won .final-score-item').live('click', ->
    if f_id = $(this).attr('data-f_id') != ''
      window.facebook_send(window.location.href, 'Can you beat me on that Sokoban level !?', f_id)
    return false
  )
