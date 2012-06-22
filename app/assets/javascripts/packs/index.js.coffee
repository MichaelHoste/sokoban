$ ->
  # Click on level (on packs/index)
  $('.levels li').live('click', ->
    level_name = $(this).attr('data-level-name')
    pack_name = $(this).closest('.pack').find('.pack-title').attr('data-pack-name')
    location.assign("/packs/#{pack_name}/levels/#{level_name}")
  )
  
  $('#limited-content').masonry(
    itemSelector: '.pack'
  )