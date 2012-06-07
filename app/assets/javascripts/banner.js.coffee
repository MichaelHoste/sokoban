$ ->
  window.banner_position = $('#banner').position().top
  
  # mouse hover on a picture in the banner to show the won levels of this user
  $('#limited-banner img')
    .mouseenter( ->
      #$(this).transition({ scale: 1.5 })
      span = $(this).next() # hidden span with won levels informations
      won_levels_ids = span.text().split(',')
      for level_id in won_levels_ids
        level_button = $(".levels .level-id[title=#{level_id}]").parent()
        $(level_button).addClass('won-by-friend')
    )
    .mouseleave( ->
      #$(this).transition({ scale: 1.0 })
      $('.levels > li').removeClass('won-by-friend')
    )
  
  # keep the friends banner on top of the page
  $(window).scroll( ->
    scroll_top = $(window).scrollTop()
    
    # banner on top !
    if scroll_top > window.banner_position
      $('#banner').css('position', 'fixed')
      $('#banner').css('top', '0px')
    # banner on this normal position
    else
      $('#banner').css('position', 'absolute')
      $('#banner').css('top', window.banner_position)
  )