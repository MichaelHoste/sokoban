# ambient component multiplied with the light source's ambient component
ambient:
  red:   1.0
  green: 1.0
  blue:  1.0
  alpha: 1.0

# diffuse component multiplied with the light source's diffuse component
diffuse:
  red:   1.0
  green: 1.0
  blue:  1.0
  alpha: 1.0

# specular component multiplied with the light source's specular component
specular:
  red:   1.0
  green: 1.0
  blue:  1.0
  alpha: 1.0

shininess: 30

texture:
  path: /images/goal64.png
  flip_y: true
  scale_x: 1.0
  scale_y: 1.0
  generate_mipmap: true
  min_filter: GL_LINEAR
  mag_filter: GL_LINEAR
  mipmap_hint: GL_DONT_CARE
  format: GL_RGBA
  data_type: GL_UNSIGNED_BYTE
  wrap_s: GL_REPEAT
  wrap_t: GL_REPEAT
  premultiply_alpha: false
  colorspace_conversion: true
