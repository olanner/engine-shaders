
#version 460

#extension GL_ARB_separate_shader_objects : enable
#extension GL_KHR_vulkan_glsl : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(set = 0, GLOBALS_SET;

layout(location = 0) out vec3 outFragPos;
layout(location = 1) out vec3 outViewDir;

vec4 positions[6] = {
    vec4(-1, 1, 0.5, 1 ),
    vec4( 1, 1 ,0.5, 1 ),
    vec4(-1,-1, 0.5, 1 ),

    vec4(-1,-1, 0.5, 1 ),
    vec4( 1, 1, 0.5, 1 ),
    vec4( 1,-1, 0.5, 1 ),
};

void main() {
    vec4 pos = positions[gl_VertexIndex];
	gl_Position = pos;
    outFragPos = pos.xyz;

    vec4 target    = GLOBALS.inverseProj * vec4(pos.x, pos.y, 1, 1);
    vec4 direction = GLOBALS.inverseView * vec4(normalize(target.xyz), 0);
    outViewDir = direction.xyz;
}
