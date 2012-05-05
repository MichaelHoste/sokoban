Jax.Controller.create "Wall", ApplicationController,
  index: ->
    @world.addObject Wall.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
