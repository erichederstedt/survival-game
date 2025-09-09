#version 300 es

in vec3 a_position;
in vec2 a_uv;

uniform mat4 u_mvp;
uniform int u_is_spine;
uniform mat2 u_spine_transform;
uniform float u_offsets[8];

out vec2 v_texcoord;
flat out int v_is_spine;

void main() {
  if (u_is_spine == 0)
  {
    gl_Position = u_mvp  * vec4(a_position, 1);
  }
  else
  {
    gl_Position = u_mvp  * vec4(a_position, 1);
  }
  v_texcoord = a_uv;
  v_is_spine = u_is_spine;
}