Jax.Controller.create "Ground", ApplicationController,
  index: ->
    @world.addObject Ground.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
