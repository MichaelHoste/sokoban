$ ->
  window.colorbox_next_level = (level_id, score_id) ->
    token_tag = window.authenticity_token()

    $.colorbox({ href:'/workflows/show_next_level/', data:{ level_id:level_id, score_id:score_id, authenticity_token:token_tag }, top:'50px', height:'602px', width:'570px', overlayClose: false, escKey: false }, ->
      $("#cboxClose").hide()
      create_thumb('next-level')
      create_thumb('this-level')

      draw = ->
        $('#game-position').html($('#game-preload').html())
      setTimeout(draw, 500)
    )

  window.colorbox_facebook = ->
    $.colorbox({href:'/login', top:'190px', height:'155px', width:'500px'}, ->
      $("#cboxClose").hide()
    )

  window.colorbox_welcome = ->
    $.colorbox({href:'/workflows/show_welcome/', top:'100px', height:'320px', width:'500px'}, ->
      $("#cboxClose").hide()
    )

  window.colorbox_controls = ->
    $.colorbox({href:'/workflows/show_controls/', top:'100px', height:'310px', width:'500px'}, ->
      $("#cboxClose").hide()
    )

  window.colorbox_rules = ->
    $.colorbox({href:'/workflows/show_rules/', top:'100px', height:'315px', width:'500px'}, ->
      $("#cboxClose").hide()
      create_thumb('rules-level1')
      create_thumb('rules-level2')
    )

  window.colorbox_facebook_page = ->
    $.colorbox({href:'/workflows/show_facebook_page/', top:'100px', height:'420px', width:'500px', overlayClose: false, escKey: false }, ->
      $("#cboxClose").hide()
    )

  window.colorbox_twitter_page = ->
    $.colorbox({href:'/workflows/show_twitter_page/', top:'100px', height:'220px', width:'500px', overlayClose: false, escKey: false }, ->
      $("#cboxClose").hide()
    )

  window.colorbox_invite_friends = ->
    $.colorbox({href:'/workflows/show_invite_friends/', top:'100px', height:'440px', width:'500px', overlayClose: false, escKey: false }, ->
      $("#cboxClose").hide()
    )

  window.colorbox_random_level = ->
    $.colorbox({href:'/workflows/show_random_level/', top:'70px', height:'510px', width:'500px' }, ->
      $("#cboxClose").hide()
      window.hide_all_tipsy()
      create_thumb('random-level')
    )

  window.colorbox_donation = ->
    $.colorbox({href:'/workflows/show_donation/', top:'50px', height:'585px', width:'600px', overlayClose: false, escKey: false }, ->
      $("#cboxClose").hide()
    )

  window.is_logged = ->
    $('#menus .fb_logged').length

  window.authenticity_token = ->
    $('meta[name="csrf-token"]').attr('content')

  bind_tipsy = ->
    $('.tips').tipsy({live: true, fade: true, opacity: 0.8 })
    $('.tips-left').tipsy({live: true, gravity: 'e', fade: true, opacity: 0.8})
    $('.tips-direct').tipsy({live: true, opacity: 0.8})

  window.hide_all_tipsy = ->
    $('.tipsy').remove()

  # level thumbs
  window.level_thumb = ->
    create_thumb('level-thumb')

  # create thumb of a level depending on the class name of the div
  # <div class="#{class_name}">
  #   <div id="#{class_name}-canvas"></div>
  # </div>
  window.create_thumb = (class_name) ->
    $(".#{class_name}").each( ->
      pack_name    = ''
      level_name   = ''
      level_line   = $(this).attr('data-level-grid')
      level_width  = $(this).attr('data-level-width')
      level_height = $(this).attr('data-level-height')
      level_canvas = "#{class_name}-canvas"

      thumb = Level.find "actual"
      thumb.create(pack_name, level_name, level_line, level_width, level_height, level_canvas)
    )

  window.change_level = ->
    # FIXME window.context.redirectTo must be sufficient and faster !
    # but it seems to have a memory leak somewhere (Jax or me ?)
    window.context.dispose()
    window.context = new Jax.Context({renderers: []})
    window.context.canvas = document.body
    window.context.setupInputDevices()
    window.context.redirectTo("level/index")

    real_name = $('#levels .is-selected').attr('data-level-real-name')
    $('#current-level-name h3').html(real_name)

    # show scores related to the new level
    window.reload_scores()
    window.reload_invitations()

  window.reload_scores = (friend_page = 1, global_page = 1) ->
    level_id = parseInt($('#levels').find('.is-selected').attr('data-level-id'))

    $.get('/scores',
      level_id:          level_id
      friend_score_page: friend_page
      global_score_page: global_page
    )
    .success((data, status, xhr) =>
      $('#scores').html(data)
      FB.XFBML.parse(document)
    )

  window.update_like_facebook_page_value = ->
    if $("#user-infos").length
      id = $("#user-infos").attr('data-id')
      $.get("/users/#{id}/is_like_facebook_page").success((data, status, xhr) ->
        if data.like == true
          $("#user-infos").attr('data-like-facebook-page', "true")
        else
          $("#user-infos").attr('data-like-facebook-page', "false")
      )

  # Disable up, down, left, right to scroll
  # left: 37, up: 38, right: 39, down: 40, spacebar: 32, pageup: 33, pagedown: 34, end: 35, home: 36
  keys = [37, 38, 39, 40]

  preventDefault = (e) ->
    e = e || window.event
    if e.preventDefault
      e.preventDefault()
    e.returnValue = false

  keydown = (e) ->
    for i in keys
      if e.keyCode == i
        preventDefault(e)
        return

  disable_scroll = ->
    document.onkeydown = keydown

  enable_scroll = ->
    document.onkeydown = null

  # automatically adapt margin of content to height of the banner
  # (useful because the banner adapt itself when scrolling and different height of banners are used)
  $('#content').css('marginTop', $('#banner').outerHeight(true))
  window.onresize = ->
    $('#content').css('marginTop', $('#banner').outerHeight(true))

  disable_scroll()

  # if new user (data-new-user="1" in <body> tag... computed server-side)
  if $('body').attr('data-new-user') == '1'
    window.colorbox_welcome()

  bind_tipsy()

  # window.colorbox_facebook_page()
  # window.colorbox_invite_friends()

  window.test_all_levels = ->
    pack_name  = $('#packs').attr('data-pack-name')
    level_name = $('#levels').find('.is-selected').next().attr('data-level-name')

    if "#{level_name}" == "undefined"
      pack_name = $('#packs select option:selected').next().attr('value')
      location.assign("/packs/#{pack_name}")
    else
      location.assign("/packs/#{pack_name}/levels/#{level_name}")

  #window.test_all_levels()
