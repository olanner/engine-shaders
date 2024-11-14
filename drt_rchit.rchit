#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : enable

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/rt_common.glsl"
#include "Shaders/pbr_functions.glsl"

layout(location = 0) rayPayloadInEXT hitPayload payload;
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
    mat3 tangentSpace = mat3(tangent.xyz, cross(normal.xyz, tangent.xyz), normal.xyz);

	vec3 worldPos = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;
	
    uvec4 texIDs = TextureIDsFromBarycentrics(barycentric, v0, v1, v2);
	vec3 albedo = 
	    texture( sampler2DArray(IMAGE_2D[texIDs.x], LINEAR_SAMPLER), vec3(uv, 0) ).xyz;
    albedo = GammaToLinear(albedo);
	vec4 material =
		texture( sampler2DArray(IMAGE_2D[texIDs.y], LINEAR_SAMPLER), vec3(uv, 0) );
    vec4 normalMap =
		texture( sampler2DArray(IMAGE_2D[texIDs.z], LINEAR_SAMPLER), vec3(uv, 0) );
    
    vec3 T = tangent.xyz;
    vec3 N = normalize(tangentSpace * (normalMap.xyz * 2.0 - 1.0)).xyz;
    vec3 V = -normalize(gl_WorldRayDirectionEXT);
    //V = normalize(GLOBALS.inverseView[3].xyz - gl_WorldRayOriginEXT);
    vec3 R = normalize(reflect(-V, N)); 

	// LIGHT
	//vec4 material = imageLoad(gBufferMat, ivec2(gl_LaunchIDEXT.xy));
	float metallic = material.y;
	float roughness = material.x;

	vec3 F0 = vec3(0.04); 
	F0 = mix(F0, albedo, metallic);

    float mipLevels = textureQueryLevels(samplerCube(IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ));
	vec2 brdf = 
        textureLod( sampler2DArray(IMAGE_2D[0], LINEAR_SAMPLER), vec3(max(dot(N, V), 0.0), roughness, 0), 0).rg;
	vec3 reflection = 
        GammaToLinear( textureLod( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), R, (mipLevels - 1) * roughness ).xyz ); // MAJOR DIFF A
	vec3 irradiance = 
        GammaToLinear( textureLod( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), N, mipLevels - 1 ).xyz ); // MAJOR DIFF B

	// Diffuse based on irradiance
	vec3 diffuse = irradiance * albedo;	

	vec3 F = max( F_SchlickR(max(dot(N, V), 0.0), F0, roughness), 0 );

	// Specular reflectance
	vec3 specular = reflection * (F0 * brdf.x + brdf.y);

	// Ambient part
	vec3 kD = 1.0 - F0;
	kD *= 1.0 - metallic;	  
	vec3 ambient = (kD * diffuse + specular);
	
	vec3 color = ambient;

	// Gamma correction
	color = (color);

	// PAYLOAD
	payload.shadedValue = color;
	payload.hit = true;
}