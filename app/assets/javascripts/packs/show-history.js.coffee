$ ->
  History = window.History

  # push the state (pack, level) on the current page into history
  window.push_this_state = ->
    pack_real_name  = $('#packs').attr('data-pack-name')
    level_real_name = $('#levels').find('.is-selected').attr('data-level-name')

    pack_slug  = $('#packs').attr('data-pack-slug')
    level_slug = $('#levels').find('.is-selected').attr('data-level-slug')

    History.pushState(null, "Sokoban - #{pack_real_name} - #{level_real_name}", "/packs/#{pack_slug}/levels/#{level_slug}")
