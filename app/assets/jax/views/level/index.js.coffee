Jax.views.push "Level/index", ->
  @glClearColor(1.0, 1.0, 1.0, 1.0);
  @glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  @world.render()
