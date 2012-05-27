Jax.getGlobal()['Square'] = Jax.Model.create

  after_initialize: ->
    @mesh = new Jax.Mesh.Quad({height:1, width:1})