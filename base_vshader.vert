
#version 460

#extension GL_ARB_separate_shader_objects : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

struct Instance 
{
    mat4 mat;
    vec3 padding0;
    uint objID;
};

layout(set = 3, binding = 0) uniform Positions {
    //mat4 mats[MAX_NUM_INSTANCES];
    //uint objIDs[MAX_NUM_INSTANCES];
    Instance instances[MAX_NUM_INSTANCES];
} uniInstances;

layout(set = 0, GLOBALS_SET;

layout(location = 0) in vec4 inPosition;
layout(location = 1) in vec4 inNormal;
layout(location = 2) in vec4 inTangent;
layout(location = 3) in vec2 inUV;
layout(location = 4) in vec2 inFiller;
layout(location = 5) in vec4 inImgIDs;

layout(location = 0) out vec4 outWorldPos;
layout(location = 1) out mat3 outTangentSpace;
layout(location = 4) out vec2 outUV;
layout(location = 5) out flat uvec4 outImgIDs;
layout(location = 6) out vec3 outViewDir;


void main() {
    Instance instance = uniInstances.instances[gl_InstanceIndex];

    // POSITION
    vec4 pos = inPosition;
    outWorldPos = instance.mat * pos;

	pos = GLOBALS.projection * GLOBALS.view * instance.mat * pos;
	gl_Position = pos;

    // TANGENT SPACE
	mat3x3 instanceRotMat = mat3x3(instance.mat);

    vec4 normal = inNormal;
	normal.xyz = normalize((instanceRotMat) * normal.xyz);

	vec4 tangent = inTangent;
	tangent.xyz = normalize((instanceRotMat) * tangent.xyz);

    outTangentSpace = mat3(tangent.xyz, cross(normal.xyz, tangent.xyz), normal.xyz);

    vec4 target    = GLOBALS.inverseProj * vec4(pos.x, pos.y, 1, 1);
    vec4 direction = GLOBALS.inverseView * vec4(normalize(target.xyz), 0);
    outViewDir = direction.xyz;

    // ETC
    outUV = inUV;
    outImgIDs = uvec4(inImgIDs);
}