#version 460
#extension GL_EXT_ray_tracing : require

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/rt_common.glsl"

layout(location = 1) rayPayloadInEXT bool shadow;

void main()
{
    shadow = false;
}