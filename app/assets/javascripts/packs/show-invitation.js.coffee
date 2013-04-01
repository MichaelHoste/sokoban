$ ->
  # load (or reload) challenge invitations template
  window.reload_invitations = ->
    if $('#user-infos').length
      current_user_id = $("#user-infos").attr('data-id')
      $.get("/users/#{current_user_id}/popular_friends")
      .success((data, status, xhr) ->
        $('#invitations').html(data)
      )

  # send new message (challenge friend)
  $('#challenges').delegate('.invite-item', 'click', ->
    message = window.facebook_invitation_message()
    window.facebook_app_request("Play Sokoban with me!", message, {})
    return false
  )

  $('#invitations-more').live('click', ->
    window.reload_invitations()
  )

  window.reload_invitations()


