$ ->  
  window.colorbox_facebook = ->
    $.colorbox({href:'/login', top:'190px', height:'263px', width:'500px'})
  
  window.next_level = ->
    $.colorbox({href:'/next_level?level_id=', top:'190px', height:'260px', width:'500px'})
    
  window.is_logged = ->
    $('#menus .fb_logout').length
  
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
  
  $('#limited-content').masonry(
    itemSelector: '.pack'
  )
  
  # send new message (invite friends)
  $('.popup').on('click', ->
    window.open(this.href, 'Facebook > New Message', 'height=300,width=600')
    return false
  )

  disable_scroll()
  