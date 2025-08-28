#version 300 es

in vec3 a_position;
in vec2 a_uv;

uniform vec2 u_test;

out vec2 v_texcoord;

void main() {
  gl_Position = vec4(a_position, 1);
  v_texcoord = a_uv + u_test;
}