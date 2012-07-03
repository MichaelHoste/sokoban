$ ->  
  window.colorbox_facebook = ->
    $.colorbox({href:'/login', top:'190px', height:'230px', width:'500px'}, ->
      $("#cboxClose").hide()
    )
  
  window.colorbox_next_level = (pack_name, level_name, score_id) ->
    token_tag = window.authenticity_token()
    
    $.colorbox({ href:'/workflows/next_level/', data:{ pack_name:pack_name, level_name:level_name, score_id:score_id, authenticity_token:token_tag }, top:'190px', height:'230px', width:'500px' }, ->
      $("#cboxClose").hide()
      window.next_level_thumb()
    )
    
  window.is_logged = ->
    $('#menus .fb_logout').length
    
  window.authenticity_token = ->
    token_tag = ""
    $('meta').each( ->
      if $(this).attr('content') != 'authenticity_token'
        token_tag = $(this).attr('content')
    )
    return token_tag
    
  # level thumbs
  window.level_thumb = ->
    create_thumb('level-thumb')
    
  # next level thumb
  window.next_level_thumb = ->
    create_thumb('next-level-thumb')
    
  # create thumb of a level depending on the class name of the div
  # <div class="#{class_name}">
  #   <div id="#{class_name}-canvas"></div>
  # </div>
  create_thumb = (class_name) ->
    $(".#{class_name}").each( ->
      pack_name    = ''
      level_name   = ''
      level_line   = $(this).attr('data-level-grid')
      level_width  = $(this).attr('data-level-width')
      level_height = $(this).attr('data-level-height')
      level_canvas = "#{class_name}-canvas"
  
      thumb = Level.find "actual"
      thumb.create_2d(pack_name, level_name, level_line, level_width, level_height, level_canvas)
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
  
  # send new message (invite friends)
  $('.popup').on('click', ->
    window.open(this.href, 'Facebook > New Message', 'height=300,width=600')
    return false
  )

  disable_scroll()

  # Show 2D or 3D div depending on the switch
  if $('#menus .switch.is-selected').text() == '3D'
    $('#raphael').hide()
    $('#webgl').show()
  else
    $('#webgl').hide()
    $('#raphael').show()
