
#version 460
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec4 inFragPos;
layout(location = 1) in mat3 inTangentSpace;
layout(location = 4) in vec2 inUV;
layout(location = 5) in flat uvec4 inImgIDs;

layout(location = 0) out vec4 outColor;

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(set = 0, GLOBALS_SET;
layout(set = 1, SAMPLERS_SET;
layout(set = 2, IMAGES_2D_SET;

void main() {
    vec4 color = texture( sampler2DArray( LINEAR_SAMPLER, IMAGE_2D[inImgIDs.x] ), vec3(uv, 0) );
    outColor = color;
}