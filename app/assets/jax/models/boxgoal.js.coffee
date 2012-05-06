Jax.getGlobal()['Boxgoal'] = Jax.Model.create

  after_initialize: ->
    @mesh = new Jax.Mesh
      material: "boxgoal"
      init: (vertices, colors, texcoords, normals, indices) ->
        @draw_mode = GL_TRIANGLE_STRIP
        
        size = 1.0 # 1 unit high, 1 unit wide
        [width, height] = [size / 2, size / 2]
            
        #                  vertex 1          vertex 2          vertex 3         vertex 4
        vertices.push     -width,height,0,  -width,-height,0,  width,height,0,  width,-height,0
        texcoords.push     1,0,              1,1,              0,0,             0,1
        normals.push       0,0,1,            0,0,1,            0,0,1,           0,0,1

