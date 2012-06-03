$ ->
  # mouse hover on a picture in the banner to show the won levels of this user
  $('#limited-banner img')
    .mouseenter( ->
      span = $(this).next() # hidden span with won levels informations
      won_levels_ids = span.text().split(',')
      for level_id in won_levels_ids
        level_button = $(".levels .level-id[title=#{level_id}]").parent()
        $(level_button).addClass('won-by-friend')
    )
    .mouseleave( ->
      $('.levels > li').removeClass('won-by-friend')
    )