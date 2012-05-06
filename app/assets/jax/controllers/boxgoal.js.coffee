Jax.Controller.create "Boxgoal", ApplicationController,
  index: ->
    @world.addObject Boxgoal.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
