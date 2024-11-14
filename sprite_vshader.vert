
#version 460

#extension GL_ARB_separate_shader_objects : enable
#extension GL_KHR_vulkan_glsl : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(set = 0, GLOBALS_SET;

struct SpriteInstance
{
    vec4  padding0;
	vec4  color;
	vec2  pos;
    vec2  pivot;
	vec2  scale;
	float imgArrID;
	float imgArrIndex;
};

layout(set = 3, binding = 0) uniform Sprites {
    SpriteInstance instances[MAX_NUM_INSTANCES];
} uniSprites;

layout(location = 0) out vec3 outFragPos;
layout(location = 1) out vec2 outUV;
layout(location = 2) out flat uint outImgArrID;
layout(location = 3) out flat uint outImgArrIndex;
layout(location = 4) out vec4 outColor;

vec2 uv[6] = {
    vec2(0, 0),
    vec2(1, 0),
    vec2(0, 1),

    vec2(0, 1),
    vec2(1, 0),
    vec2(1, 1),
};

vec4 positions[6] = {
    vec4(0, 1, 0.5, 1),
    vec4(1, 1, 0.5, 1),
    vec4(0, 0, 0.5, 1),

    vec4(0, 0, 0.5, 1),
    vec4(1, 1, 0.5, 1),
    vec4(1, 0, 0.5, 1),
};

void main() {

    SpriteInstance instance = uniSprites.instances[gl_InstanceIndex];
    vec4 pos = positions[gl_VertexIndex];
    pos.xy += instance.pivot.xy;
    pos.x *= (GLOBALS.resolution.y / GLOBALS.resolution.x);
    pos.xy *= instance.scale;
    pos.xy += instance.pos.xy;
	gl_Position = pos;

    outFragPos = pos.xyz;
    outUV = uv[gl_VertexIndex].xy;
    outImgArrID = uint(instance.imgArrID);
    outImgArrIndex = uint(instance.imgArrIndex);
    outColor = instance.color;
}