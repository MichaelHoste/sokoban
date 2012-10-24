Jax.views.push "Level/index", ->
  # master
  @context.gl.clearColor(1.0, 1.0, 1.0, 1.0)
  @context.gl.clear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

  # 2.0.10 (will be deprecated)
  #@glClearColor(1.0, 1.0, 1.0, 1.0)
  #@glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  
  @world.render()
