#= require packs/show-history
#= require packs/show-level-thumb

$ ->
  # Initialize webgl and load selected level
  window.context = new Jax.Context('webgl')
  window.context.redirectTo('level/index')
  
  # Scroll the left menu to the selected level
  level_button = $('#levels .is-selected')
  $('#levels').scrollTo(level_button, 1000, { easing:'swing', offset: -10 } )
  
  # Click on level (on packs/show)
  $('#levels li').live('click', ->
    $(this).parent().find(".is-selected").removeClass('is-selected')
    $(this).addClass('is-selected')
    
    # change the level (the '.is-selected' level is chosen)
    window.change_level()
    
    # change the url and save related state (pack and level)
    window.push_this_state()
  )
