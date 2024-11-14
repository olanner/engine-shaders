#version 460
#extension GL_EXT_ray_tracing : require

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/rt_common.glsl"
#include "Shaders/pbr_functions.glsl"

layout(location = 0) rayPayloadInEXT hitPayload payLoad;

void main()
{
    vec3 rayDir = gl_WorldRayDirectionEXT;
    payLoad.shadedValue = 
    GammaToLinear(textureLod( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), rayDir, 0 ).xyz);
        //(texture( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), rayDir ).xyz);
    payLoad.hit = false;
}