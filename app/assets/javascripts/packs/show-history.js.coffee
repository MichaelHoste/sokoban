$ ->
  History = window.History

  # push the state (pack, level) on the current page into history
  window.push_this_state = ->
    pack_real_name  = $('#packs').attr('data-pack-real-name')
    level_real_name = $('#levels').find('.is-selected').attr('data-level-real-name')

    pack_name      = $('#packs').attr('data-pack-name')
    level_name     = $('#levels').find('.is-selected').attr('data-level-name')

    History.pushState(null, "#{pack_real_name} / #{level_real_name}", "/packs/#{pack_name}/levels/#{level_name}")
