#version 300 es

precision highp float;

in vec2 v_texcoord;
flat in int v_is_spine;

uniform sampler2D u_texture;

out vec4 outColor;

void main() {
  outColor = texture(u_texture, v_texcoord);
  outColor = vec4(1.0);
  if (v_is_spine == 1)
    outColor = vec4(1.0, 0.0, 0.0, 1.0);
}