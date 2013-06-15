$ ->
  $('#users-show .level').each( ->
    id = $(this).attr('data-level-id')
    window.create_thumb("level-#{id}")
  )
