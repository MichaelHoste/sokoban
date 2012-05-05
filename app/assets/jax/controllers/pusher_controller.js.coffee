Jax.Controller.create "Pusher", ApplicationController,
  index: ->
    @world.addObject Pusher.find "actual"
  
  # Some special actions are fired whenever the corresponding input is
  # received from the user.
  mouse_pressed: (event) ->
