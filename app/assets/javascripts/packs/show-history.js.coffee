$ ->
  History = window.History
  
  # push the state (pack, level) on the current page into history
  window.push_this_state = ->
    pack_name = $('#packs > li').text()
    level_name = $('#levels').find('.is-selected').attr('data-level-name')
    History.pushState(null, "Sokoban #{pack_name}/#{level_name}", "/packs/#{pack_name}/levels/#{level_name}")
