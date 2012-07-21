$ ->
  # push the state (pack, level) on the current page into history
  window.push_this_state = ->
    if history and history.pushState
      pack_name = $('#packs > li').text()
      level_name = $('#levels').find('.is-selected').attr('data-level-name')
      
      history.pushState(null, "Sokoban #{pack_name}/#{level_name}", "/packs/#{pack_name}/levels/#{level_name}")

  # replace the initial state
#  if history and history.replaceState
#    pack_name = $('#packs > li').text()
#    level_name = $('#levels').find('.is-selected').attr('data-level-name')
#    
#    history.replaceState(null, "Sokoban #{pack_name}/#{level_name}", "/packs/#{pack_name}/levels/#{level_name}")

  # if return to previous state (back), load the related state level
  $(window).bind('popstate', (event) ->
    location.assign(location.href)
  )