$ ->
  # load (or reload) challenge invitations template
  reload_invitations = ->
    current_user_id = $("#user-infos").attr('data-id')
    $.get("/users/#{current_user_id}/popular_friends")
    .success((data, status, xhr) ->
      $('#invitations').html(data)
    )
  
  # send new message (challenge friend)
  $('#invitations .invite-friend').live('click', ->
    window.facebook_send(window.location.href, "Can you beat me on that Sokoban level !?", $(this).closest('.invite-item').attr('data-f_id'))
    return false
  )
  
  $('#invitations-more').live('click', ->
    reload_invitations()
  )
  
  reload_invitations()