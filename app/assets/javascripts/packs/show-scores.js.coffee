$ ->
  # Refresh scores when click on "more scores" of "friends scores"
  $('#scores').on('click', '#more-friend-score', ->
    friend_page = parseInt($(this).attr('data-page')) + 1
    global_page = parseInt($('#more-global-score').attr('data-page'))

    window.reload_scores(friend_page, global_page)
  )

  # Refresh scores when click on "more scores" of "global scores"
  $('#scores').on('click', '#more-global-score', ->
    friend_page = parseInt($('#more-friend-score').attr('data-page'))
    global_page = parseInt($(this).attr('data-page')) + 1

    window.reload_scores(friend_page, global_page)
  )

  $('#scores').delegate('.score-item .brag', 'click', ->
    if $(this).attr('data-is-friend') == 'true'
      window.facebook_send_to_feed_in_ladder($(this).attr('data-f_id'),
                                             $(this).attr('data-score-worse') == "true")
    else
      window.facebook_send_invitation_message($(this).attr('data-f_id'))
    return false
  )

  $('#game-won').on('click', '.final-score-item', ->
    window.facebook_send_to_feed_in_ladder($(this).attr('data-f_id'),
                                           $(this).attr('data-score-worse') == "true",
                                           $('#final-score .score-pushes .num').html(),
                                           $('#final-score .score-moves .num').html())
    return false
  )

  $('#game-won').on('click', '#share-on-fb', ->
    window.facebook_send_to_feed('', $('#final-score .score-pushes .num').html(),
                                     $('#final-score .score-moves .num').html())
  )

  bragging = false

  $('#game-won').on('.final-score-item[data-score-worse="true"], .score-item[data-score-worse="true"]', 'mouseover', ->
    #$(this).parent().find('.brag').hide()
    $(this).parent().find('.score-name, .score-pushes').show()
    $(this).find('.score-name, .score-pushes').hide()
    #$(this).find('.brag').show()
    bragging = true
  )

  $('#game-won').on('.final-score-item[data-score-worse="true"], .score-item[data-score-worse="true"]', 'mouseout', ->
    #$(this).find('.brag').hide()
    $(this).find('.score-name, .score-pushes').show()
    bragging = false
  )

  # hide_brag_anim = ->
  #   if not bragging
  #     worse_scores = $('.final-score-item[data-score-worse="true"]')
  #     worse_scores.find('.brag').hide()
  #     worse_scores.find('.score-name').show()
  #     worse_scores.find('.score-pushes').show()
  #   setTimeout(show_brag_anim, 3000)

  # show_brag_anim = ->
  #   if not bragging
  #     worse_scores = $('.final-score-item[data-score-worse="true"]')
  #     worse_scores.find('.score-name').hide()
  #     worse_scores.find('.score-pushes').hide()
  #     worse_scores.find('.brag').show()
  #   setTimeout(hide_brag_anim, 500)

  # setTimeout(show_brag_anim, 1000)
