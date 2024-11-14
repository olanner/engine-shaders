#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/rt_common.glsl"

layout(location = 0) rayPayloadInEXT hitPayload payLoad;
layout(location = 1) rayPayloadEXT bool shadow;
layout(location = 2) rayPayloadEXT hitPayload ambientLoad;
hitAttributeEXT vec3 attribs;

void main()
{
	uint instanceID = gl_InstanceID;
	uint objID = gl_InstanceCustomIndexEXT;
	uint baseIndex = gl_PrimitiveID * 3;
	ivec3 indices = ivec3( meshIndices[objID].i[baseIndex+0], 
						   meshIndices[objID].i[baseIndex+1], 
						   meshIndices[objID].i[baseIndex+2] );
	Vertex v0 = meshVertices[objID].v[indices.x];
	Vertex v1 = meshVertices[objID].v[indices.y];
	Vertex v2 = meshVertices[objID].v[indices.z];

	vec3 barycentric = vec3(1.0 - attribs.x - attribs.y, attribs.x, attribs.y);

	// FRAGMENT DATA
	vec2 uv = v0.uv * barycentric.x + v1.uv * barycentric.y + v2.uv * barycentric.z;
	vec4 normal = v0.normal * barycentric.x + v1.normal * barycentric.y + v2.normal * barycentric.z;
		mat3x3 instanceRotMat = mat3x3(gl_ObjectToWorldEXT);
		normal.xyz = normalize((instanceRotMat) * normal.xyz);
	vec4 tangent = v0.tangent * barycentric.x + v1.tangent * barycentric.y + v2.tangent * barycentric.z;
		tangent.xyz = normalize((instanceRotMat) * tangent.xyz);

	
	vec3 camPos = gl_WorldRayOriginEXT;
	vec3 worldPos = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;
	
	
	uint albedoID = 0;
	albedoID += uint(v0.texIDs.x) * uint( barycentric.x > barycentric.y && barycentric.x > barycentric.z );
	albedoID += uint(v1.texIDs.x) * uint( barycentric.y > barycentric.x && barycentric.y > barycentric.z );
	albedoID += uint(v2.texIDs.x) * uint( barycentric.z > barycentric.x && barycentric.z > barycentric.y );
	vec4 albedo = 
		texture( sampler2DArray(IMAGE_2D[albedoID], LINEAR_SAMPLER), vec3(uv, 0) );

	uint materialID = 0;
	materialID += uint(v0.texIDs.y) * uint( barycentric.x > barycentric.y && barycentric.x > barycentric.z );
	materialID += uint(v1.texIDs.y) * uint( barycentric.y > barycentric.x && barycentric.y > barycentric.z );
	materialID += uint(v2.texIDs.y) * uint( barycentric.z > barycentric.x && barycentric.z > barycentric.y );
	vec4 material =
		texture( sampler2DArray(IMAGE_2D[materialID], LINEAR_SAMPLER), vec3(uv, 0) );


	// LIGHT
	vec3 dirLight = normalize(vec3(0,-1,-1));
	
	// TRACE DIRECTIONAL SHADOW
	shadow = true;
	traceRayEXT(
		topLevelAS[0],     // acceleration structure
		gl_RayFlagsTerminateOnFirstHitEXT | gl_RayFlagsOpaqueEXT | gl_RayFlagsSkipClosestHitShaderEXT,       // rayFlags
		0xFF,           // cullMask
		0,              // sbtRecordOffset
		0,              // sbtRecordStride
		1,              // missIndex
		worldPos.xyz + normal.xyz * 0.001,     // ray origin
		0.001,           // ray min range
		-dirLight,  // ray direction
		10000,           // ray max range
		1               // payload (location = 0)
	);
	
	float directional = dot(normal.xyz, -dirLight) * float(!shadow);
	directional = clamp(directional, 0, 1);
	vec3 lambert = albedo.xyz * 0.25 + (albedo.xyz * directional);

	// PAYLOAD
	payLoad.shadedValue = lambert;
	//payLoad.tangentSpace = mat3(tangent.xyz, cross(normal.xyz, tangent.xyz), normal.xyz);
	payLoad.normal = normal.xyz;
	payLoad.worldPos = worldPos.xyz;
	payLoad.roughness = material.x;
	payLoad.hit = true;
}
