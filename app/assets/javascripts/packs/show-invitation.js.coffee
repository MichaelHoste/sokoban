$ ->
  # send new message (challenge friend)
  $('#invitations .invite-friend').on('click', ->
    window.facebook_send(window.location.href, "Can you beat me on that Sokoban level !?", $(this).closest('.invite-item').attr('data-f_id'))
    return false
  )