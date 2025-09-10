#version 300 es

in vec3 a_position;
in vec2 a_uv;

uniform mat4 u_mvp;
uniform int u_is_spine;
uniform mat4 u_bone_transform;
// uniform float u_spine_transform[6];
// uniform float u_spine_offsets[8];
uniform float u_spine_uvs[8];

out vec2 v_texcoord;
flat out int v_is_spine;

void main() {
  if (u_is_spine == 0)
  {
    gl_Position = u_mvp  * vec4(a_position, 1);
    v_texcoord = a_uv;
  }
  else
  {
    /*
    vec2 pos = vec2(0.0);
    
    float a = u_spine_transform[0];
    float b = u_spine_transform[1];
    float c = u_spine_transform[2];
    float d = u_spine_transform[3];

    float offsetX = u_spine_offsets[gl_VertexID*2];
    float offsetY = u_spine_offsets[gl_VertexID*2+1];

    pos.x = offsetX * a + offsetY * b + u_spine_transform[4];
		pos.y = offsetX * c + offsetY * d + u_spine_transform[5];

    gl_Position = u_mvp  * vec4(pos, 0.0, 1.0);
    */
    gl_Position = u_mvp * u_bone_transform * vec4(a_position, 1.0);

    float uvX = u_spine_uvs[gl_VertexID*2];
    float uvY = u_spine_uvs[gl_VertexID*2+1];
    v_texcoord = vec2(uvX, uvY);
  }
  v_is_spine = u_is_spine;
}