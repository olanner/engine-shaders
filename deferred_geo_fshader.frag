#version 460
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec4 inWorldPos;
layout(location = 1) in mat3 inTangentSpace;
layout(location = 4) in vec2 inUV;
layout(location = 5) in flat uvec4 inImgIDs;
layout(location = 6) in vec3 inViewDir;

layout(location = 0) out vec4 outAlbedo;
layout(location = 1) out vec4 outWorldPos;
layout(location = 2) out vec4 outNormal;
layout(location = 3) out vec4 outMaterial;


#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(set = 1, SAMPLERS_SET;
layout(set = 2, IMAGES_2D_SET;

void main() {
    vec4 albedo = 
        texture(sampler2DArray(IMAGE_2D[inImgIDs.x], LINEAR_SAMPLER), vec3(inUV, 0));
    vec4 material = 
        texture(sampler2DArray(IMAGE_2D[inImgIDs.y], LINEAR_SAMPLER), vec3(inUV, 0));
    vec3 normal = 
        texture(sampler2DArray(IMAGE_2D[inImgIDs.z], LINEAR_SAMPLER), vec3(inUV, 0)).xyz;

    outAlbedo = albedo;

    normal = normalize(inTangentSpace * (normal * 2.0 - 1.0));

    //vec3 normal = inTangentSpace[2];
    vec3 tangent = inTangentSpace[0];
    //tangent = normalize(tangent - dot(tangent, normal) * normal);
    vec4 outEncodedTangentSpace = vec4(0);
    outEncodedTangentSpace.xy = encode(normal.xyz, inViewDir);
    outEncodedTangentSpace.zw = encode(tangent.xyz, inViewDir);
    outNormal = outEncodedTangentSpace;

    outWorldPos = vec4(inWorldPos.xyz,1);
    outMaterial = material;
    outMaterial.x = material.x * material.x;
    
}