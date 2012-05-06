Jax.Controller.create "Pushergoal", ApplicationController,
  index: ->
    @world.addObject Pushergoal.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
