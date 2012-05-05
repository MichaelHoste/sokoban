Jax.Controller.create "Goal", ApplicationController,
  index: ->
    @world.addObject Goal.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
