$ ->
  window.colorbox_facebook = ->
    $.colorbox({href:'/login', top:'190px', height:'260px', width:'500px'})
  
  window.next_level() = ->
    $.colorbox({href:'/next_level?level_id=', top:'190px', height:'260px', width:'500px'})
    