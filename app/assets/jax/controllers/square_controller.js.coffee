Jax.Controller.create "Square", ApplicationController,
  index: ->
    @world.addObject Square.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
