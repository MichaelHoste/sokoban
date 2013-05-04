# connect to facebook
window.fbAsyncInit = ->
  FB.init(
    appId: $('meta[property="fb:app_id"]').attr('content')
    channelUrl: '//sokoban.be/channel.html'
    status: true
    xfbml: true
    cookie: true
    frictionlessRequests: true
  )

$ ->
  window.current_level_id = ->
    $('#levels').find('.is-selected').attr('data-level-id')

  window.current_level_name = ->
    $('#levels').find('.is-selected').attr('data-level-real-name')

  window.current_level_thumb = ->
    $('#levels').find('.is-selected').attr('data-level-thumb')

  window.current_url = ->
    "https://sokoban.be/levels/#{window.current_level_id()}"

  update_send_invitations_at = ->
    current_user_id = $("#user-infos").attr('data-id')
    $.post("/users/#{current_user_id}/update_send_invitations_at",
      authenticity_token: window.authenticity_token()
    )

  post_to_fb = (options) ->
    FB.ui(options, (request) ->
      if request != null and request != undefined # if not click on cancel
        update_send_invitations_at()
    )

  window.facebook_send = (description, to = "", name = window.current_level_name()) ->
    options =
      method:       'send'
      link:         window.current_url()
      name:         name
      description:  description
      to:           to
      picture:      window.current_level_thumb()

    post_to_fb(options)

  # iteration > 0 if must be called recursively by batch of 50 friends (in the DOM)
  window.facebook_app_request = (title, message, to, filters = [], data = "", iteration = 0) ->
    options =
      method:       'apprequests'
      redirect_uri: window.current_url()
      title:        title
      message:      message
      to:           if iteration == 0 then to else $("#fb-friends .batch-#{iteration}").html()
      filters:      filters
      data:         data

    if iteration == 0 or not $("#fb-friends .batch-#{iteration+1}").length
      post_to_fb(options)
    else
      FB.ui(options, (request) ->
        if request != null # if click on cancel, no more recursive calls
          update_send_invitations_at()
          window.facebook_app_request(title, message, to, filters, data, iteration + 1)
      )

  window.facebook_feed = (name, description, to = "") ->
    options =
      method:       'feed'
      redirect_uri: window.current_url()
      picture:      window.current_level_thumb()
      link:         window.current_url()
      name:         name
      caption:      window.current_level_name()
      description:  description
      to:           to

    post_to_fb(options)

  window.facebook_send_invitation_message = (to = "") ->
    window.facebook_send('Can you solve this Sokoban level?', to)

  window.facebook_send_custom_invitation_message = ->
    current_user_id = $("#user-infos").attr('data-id')
    $.get("/users/#{current_user_id}/custom_invitation").success((data, status, xhr) ->
      if data.f_id
        window.facebook_send(data.description, data.f_id, data.name)
    )

  window.facebook_send_to_feed = (to = "", pushes = -1, moves = -1) ->
    current_level_solved = $('#levels li.is-selected .s-icon-star').length
    if current_level_solved
      if pushes != -1 and moves != -1
        description = "I just solved this Sokoban level with #{pushes} pushes and #{moves} moves and I bet that you can't!"
      else
        description = "I just solved this Sokoban level and I bet that you can't!"
    else
      description = "I can't solve this Sokoban level, can you help me?"

    window.facebook_feed("Can you solve this Sokoban level?", description, to)

  window.facebook_send_to_feed_in_ladder = (to, brag, pushes = -1, moves = -1) ->
    if brag
      title  = "Can you solve this Sokoban level?"
      if pushes != -1 and moves != -1
        description = "I just beat your score on that Sokoban level! Can you do better than #{pushes} pushes and #{moves} moves?"
      else
        description = "I just beat your score on that Sokoban level! Can you do better?"
    else
      title       = "Nice Job!"
      description = "I can't solve this Sokoban level with so few pushes and moves as you!"

    window.facebook_feed(title, description, to)

  window.facebook_send_app_request = (to = '', filters = ['app_non_users']) ->
    total_success = $('#user-infos').attr('data-global-success')
    if total_success != '' and parseInt(total_success) <= 5
      message = "Can you solve as many Sokoban levels as me?"
    else
      message = "I already solved #{total_success} Sokoban levels, can you beat me?"

    window.facebook_app_request("Play Sokoban with me!", message, to, filters)

  window.facebook_send_recursive_app_request = ->
    total_success = $('#user-infos').attr('data-global-success')
    if total_success != '' and parseInt(total_success) <= 5
      message = "Can you solve as many Sokoban levels as me?"
    else
      message = "I already solved #{total_success} Sokoban levels, can you beat me?"

    window.facebook_app_request('Play Sokoban with me!' , message, '', '', '', 1)

  window.facebook_send_app_request_to_challenge_users = ->
    f_ids = $('#invitations').find('.invite-item').map( ->
      $(this).attr('data-f_id')
    ).get().join()
    window.facebook_send_app_request(f_ids, [])
