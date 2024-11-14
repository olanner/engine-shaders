
#version 460
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec3 inFragPos;
layout(location = 1) in vec3 inViewDir;

layout(location = 0) out vec4 outColor;

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout (set = 1, IMAGES_STORAGE_SET;
layout (input_attachment_index = 0, set = 2, binding = 0) uniform subpassInput intermediate;

void main() {
    ivec4 pos = ivec4(gl_FragCoord);
    vec4 color = imageLoad(IMAGE_STORAGE[0], pos.xy);
    color = mix(color, subpassLoad(intermediate), subpassLoad(intermediate).w);
    outColor = color;
}