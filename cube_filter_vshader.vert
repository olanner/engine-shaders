
#version 460

#extension GL_ARB_separate_shader_objects : enable
#extension GL_KHR_vulkan_glsl : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(location = 0) out vec3 outFragPos;
layout(location = 1) out flat int outCubeID;
layout(location = 2) out flat int outMip;


vec4 positions[6] = {
    vec4(-1, 1, 0.5, 1 ),
    vec4( 1, 1 ,0.5, 1 ),
    vec4(-1,-1, 0.5, 1 ),

    vec4(-1,-1, 0.5, 1 ),
    vec4( 1, 1, 0.5, 1 ),
    vec4( 1,-1, 0.5, 1 ),
};

void main() {
    vec4 pos = positions[gl_VertexIndex - gl_BaseVertex];
	gl_Position = pos;
    outFragPos = pos.xyz;
    
    outCubeID = (gl_BaseVertex);
    outMip = (gl_InstanceIndex);
}