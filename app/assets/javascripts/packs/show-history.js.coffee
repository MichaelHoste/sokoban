$ ->
  History = window.History

  # push the state (pack, level) on the current page into history
  window.push_this_state = ->
    pack_real_name  = $('#packs').attr('data-pack-name')
    level_real_name = $('#levels').find('.is-selected').attr('data-level-name')
    level_id        = $('#levels').find('.is-selected').attr('data-level-id')

    pack_slug  = $('#packs').attr('data-pack-slug')
    level_slug = $('#levels').find('.is-selected').attr('data-level-slug')

    new_description = $('meta[name="description"]').attr('content')
    splitted        = new_description.split('[')
    new_description = "#{level_real_name} [#{splitted.slice(1).join("[")}" # in case of several '['

    new_keywords = $('meta[name="keywords"]').attr('content')
    splitted     = new_description.split(',')
    new_keywords = "#{new_keywords}, #{splitted.slice(1).join(",")}" # in case of several ',''

    # name and url on level
    $('#current-level-name h2').html(level_real_name)
    $('#current-level-name a').attr('href', "/packs/#{pack_slug}/levels/#{level_slug}")

    # standard description and keywords
    $('meta[name="description"]').attr(                'content', new_description)
    $('meta[name="keywords"]').attr(                   'content', new_keywords)

    # Facebook stuff
    $('meta[property="og:url"]').attr(                 'content', "/packs/#{pack_slug}/levels/#{level_slug}")
    $('meta[property="og:image"]').attr(               'content', "https://sokoban-game.com/images/levels/#{level_id}.png")
    $('meta[property="og:title"]').attr(               'content', "#{level_real_name}")
    $('meta[property="sokoban_game:level_name"]').attr('content', "#{level_real_name}")

    History.pushState(null, "#{pack_real_name} - #{level_real_name}", "/packs/#{pack_slug}/levels/#{level_slug}")
