$ ->
  $('#users-show .level, #users-latest_levels .level, #users-levels_to_solve .level, #users-scores_to_improve .level').each( ->
    id = $(this).attr('data-level-id')
    window.create_thumb("level-#{id}")
  )
