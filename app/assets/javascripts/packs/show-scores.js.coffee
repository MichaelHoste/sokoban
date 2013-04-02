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
    window.facebook_send_to_feed_in_ladder($(this).attr('data-f_id'), $(this).attr('data-score-worse') == "true")
    return false
  )

  $('#game-won .final-score-item[data-score-worse="true"]')
    .live('mouseover', ->
      $(this).find('.score-name').hide()
      $(this).find('.score-pushes').hide()
      $(this).find('#brag').show()
    )
    .live('mouseout', ->
      $(this).find('#brag').hide()
      $(this).find('.score-name').show()
      $(this).find('.score-pushes').show()
    )

  hide_brag_anim = ->
    worse_scores = $('#game-won .final-score-item[data-score-worse="true"]')
    worse_scores.find('#brag').hide()
    worse_scores.find('.score-name').show()
    worse_scores.find('.score-pushes').show()
    setTimeout(show_brag_anim, 3000)

  show_brag_anim = ->
    worse_scores = $('#game-won .final-score-item[data-score-worse="true"]')
    worse_scores.find('.score-name').hide()
    worse_scores.find('.score-pushes').hide()
    worse_scores.find('#brag').show()
    setTimeout(hide_brag_anim, 1500)

  show_brag_anim()
