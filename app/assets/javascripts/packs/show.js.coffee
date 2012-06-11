$ ->
  # Initialize webgl and load selected level
  window.context = new Jax.Context('webgl')
  window.context.redirectTo("level/index")
  
  # Scroll the left menu to the selected level
  level_button = $('#levels .is-selected')
  $('#levels').scrollTo(level_button, 1000, { easing:'swing', offset: -10 } )
  
  # Click on level (on packs/show)
  $("#levels li").live('click', ->
    $(this).parent().find(".is-selected").removeClass("is-selected")
    $(this).addClass("is-selected")

    # FIXME window.context.redirectTo must be sufficient and faster !
    # but it seems to have a memory leak somewhere (Jax or me ?)
    window.context.dispose()
    window.context = new Jax.Context('webgl')
    window.context.redirectTo("level/index")
  )