$ ->
  # Click on level (on packs/index)
  $('.levels li').live('click', ->
    level_name = $(this).attr('title')
    pack_name = $(this).closest('.pack').find('.pack-title').attr('title')
    location.assign("/packs/#{pack_name}/levels/#{level_name}")
  )
  
  $('#limited-content').masonry(
    itemSelector: '.pack'
  )