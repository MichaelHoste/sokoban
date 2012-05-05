Jax.Controller.create "Box", ApplicationController,
  index: ->
    @world.addObject Box.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
