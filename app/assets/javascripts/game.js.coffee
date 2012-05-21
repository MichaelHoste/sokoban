$ ->  
  # initialize webgl
  window.context = new Jax.Context('webgl')
  
  # Click on level
  $("#levels li").live('click', ->
    $(this).parent().find(".is-selected").removeClass("is-selected")
    $(this).addClass("is-selected")
    window.context.redirectTo("level/index")
  )
  
  # select first pack and first level
  $("#packs li:first").addClass("is-selected")
  $("#levels li:first").addClass("is-selected")
  
  # load selected level in webgl
  window.context.redirectTo("level/index")
