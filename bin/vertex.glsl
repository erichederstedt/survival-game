#version 300 es

in vec3 a_position;
in vec2 a_uv;

uniform mat4 u_mvp;
uniform int u_is_spine;
uniform float u_spine_transform[4];
uniform float u_offsets[8];
uniform vec2 u_spine_position;

out vec2 v_texcoord;
flat out int v_is_spine;

void main() {
  if (u_is_spine == 0)
  {
    gl_Position = u_mvp  * vec4(a_position, 1);
  }
  else
  {
    vec2 pos = vec2(0.0);
    
    float a = u_spine_transform[0];
    float b = u_spine_transform[1];
    float c = u_spine_transform[2];
    float d = u_spine_transform[3];

    float offsetX = u_offsets[gl_VertexID*2];
    float offsetY = u_offsets[gl_VertexID*2+1];

    pos.x = offsetX * a + offsetY * b + u_spine_position.x;
		pos.y = offsetX * c + offsetY * d + u_spine_position.y;

    gl_Position = u_mvp  * vec4(pos, 0.0, 1.0);
  }
  v_texcoord = a_uv;
  v_is_spine = u_is_spine;
}