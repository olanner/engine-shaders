
#version 460
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec3 inFragPos;
layout(location = 1) in vec2 inUV;
layout(location = 2) in flat uint inImgArrID;
layout(location = 3) in flat uint inImgArrIndex;
layout(location = 4) in vec4 inColor;

layout(location = 0) out vec4 outColor;

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

//layout(set = 0, GLOBALS_SET;
layout(set = 1, SAMPLERS_SET;
layout(set = 2, IMAGES_2D_SET;

void main() {
    vec4 color = texture(sampler2DArray(IMAGE_2D[inImgArrID], NEAREST_SAMPLER), vec3(inUV, inImgArrIndex));
    color *= inColor;

    outColor = color;
}