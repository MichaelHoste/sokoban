$ ->
  window.banner_position = $('#banner').position().top
  
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
  
  # keep the friends banner on top of the page
  $(window).scroll( ->
    scroll_top = $(window).scrollTop()
    if scroll_top > window.banner_position
      $('#banner').css('top', scroll_top)
    else
      $('#banner').css('top', window.banner_position)
  )