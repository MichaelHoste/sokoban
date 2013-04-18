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
    window.facebook_send_app_request_to_challenge_users()
    return false
  )

  $('#invitations-more').live('click', ->
    window.reload_invitations()
  )

  window.reload_invitations()


