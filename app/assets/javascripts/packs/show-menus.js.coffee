display_stars = ->
  if $('#user-infos').length
    levels_string = $('#user-infos').attr('data-won-levels-list')
    won_levels_list = $.trim(levels_string).split(',')
    for level_id in won_levels_list
      span = $("#level-#{level_id} .star")
      $(span).removeClass('s-icon-star-empty')
      $(span).addClass('s-icon-star')

  if $("#menus")
    load_level_id = $("#menus").attr('data-level-id')
    $("#level-#{load_level_id}").addClass('is-selected') if $("#level-#{load_level_id}").length

$ ->
  display_stars()
