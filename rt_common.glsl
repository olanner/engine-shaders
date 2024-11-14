

#extension GL_EXT_scalar_block_layout : enable
#extension GL_EXT_ray_tracing : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(set = 0, GLOBALS_SET;
layout(set = 1, SAMPLERS_SET;

layout(set = 2, IMAGES_2D_SET;
layout(set = 2, IMAGES_STORAGE_SET;
layout(set = 2, IMAGES_CUBE_SET;

layout(set = 3, binding = 0) uniform accelerationStructureEXT topLevelAS[SET_TLAS_COUNT];

struct hitPayload
{
	vec3  shadedValue;
	bool  hit;
};

struct Vertex
{
	vec4 position;
	vec4 normal;
	vec4 tangent;
	vec2 uv;
	vec2 filler;
	vec4 texIDs;
};

layout(set = 4, binding = 0, scalar) buffer Vertices { Vertex v[]; } meshVertices[MAX_NUM_MESHES];
layout(set = 4, binding = 1)         buffer Indices  { uint i[]; }   meshIndices[MAX_NUM_MESHES];

layout(set = 5, binding = 0, rgba8)	  uniform image2D gBufferAlb;
layout(set = 5, binding = 1, rgba32f) uniform image2D gBufferPos;
layout(set = 5, binding = 2, rgba32f) uniform image2D gBufferNrm;
layout(set = 5, binding = 3, rgba8)   uniform image2D gBufferMat;

uvec4 TextureIDsFromBarycentrics(vec3 barycentrics, Vertex v0, Vertex v1, Vertex v2)
{
	uvec4 ret = uvec4(0);
	ret.x += uint(v0.texIDs.x) * uint( barycentrics.x > barycentrics.y && barycentrics.x > barycentrics.z );
	ret.x += uint(v1.texIDs.x) * uint( barycentrics.y > barycentrics.x && barycentrics.y > barycentrics.z );
	ret.x += uint(v2.texIDs.x) * uint( barycentrics.z > barycentrics.x && barycentrics.z > barycentrics.y );
	ret.y += uint(v0.texIDs.y) * uint( barycentrics.x > barycentrics.y && barycentrics.x > barycentrics.z );
	ret.y += uint(v1.texIDs.y) * uint( barycentrics.y > barycentrics.x && barycentrics.y > barycentrics.z );
	ret.y += uint(v2.texIDs.y) * uint( barycentrics.z > barycentrics.x && barycentrics.z > barycentrics.y );
	ret.z += uint(v0.texIDs.z) * uint( barycentrics.x > barycentrics.y && barycentrics.x > barycentrics.z );
	ret.z += uint(v1.texIDs.z) * uint( barycentrics.y > barycentrics.x && barycentrics.y > barycentrics.z );
	ret.z += uint(v2.texIDs.z) * uint( barycentrics.z > barycentrics.x && barycentrics.z > barycentrics.y );
	ret.w += uint(v0.texIDs.z) * uint( barycentrics.x > barycentrics.y && barycentrics.x > barycentrics.z );
	ret.w += uint(v1.texIDs.z) * uint( barycentrics.y > barycentrics.x && barycentrics.y > barycentrics.z );
	ret.w += uint(v2.texIDs.z) * uint( barycentrics.z > barycentrics.x && barycentrics.z > barycentrics.y );

	return ret;
}