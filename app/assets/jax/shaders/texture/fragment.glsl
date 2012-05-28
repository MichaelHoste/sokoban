/*
  Fragment shader HACK to make the texture shader produce correct results
  when no lights are present.
  Remove it when switching to new Jax version
  http://blog.jaxgl.com/forum/jax-group1/jax-forum1/textures-altered-colors-thread24/
*/

void main(inout vec4 ambient, inout vec4 diffuse, inout vec4 specular) {
  ambient = texture2D(Texture, vTexCoords * vec2(TextureScaleX, TextureScaleY));
  diffuse = specular = vec4(0);
}
