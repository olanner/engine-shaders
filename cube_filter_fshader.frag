
#version 460
#extension GL_ARB_separate_shader_objects : enable
#extension GL_EXT_samplerless_texture_functions : enable

layout(location = 0) in vec3 inFragPos;
layout(location = 1) in flat int inCubeID;
layout(location = 2) in flat int inMip;

layout(location = 0) out vec4 outColor0;
layout(location = 1) out vec4 outColor1;
layout(location = 2) out vec4 outColor2;
layout(location = 3) out vec4 outColor3;
layout(location = 4) out vec4 outColor4;
layout(location = 5) out vec4 outColor5;


#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"

layout(set = 0, SAMPLERS_SET;
layout(set = 1, IMAGES_CUBE_SET;

vec3 LinearToGamma(vec3 linearColor)
{
    return pow((linearColor), vec3(1.0 / 2.2));
}

vec3 GammaToLinear(vec3 color)
{
    return pow((color), vec3(2.2));
}

// Based on http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
float random(vec2 co)
{
	float a = 12.9898;
	float b = 78.233;
	float c = 43758.5453;
	float dt= dot(co.xy ,vec2(a,b));
	float sn= mod(dt,3.14);
	return fract(sin(sn) * c);
}

vec2 hammersley2d(uint i, uint N) 
{
	// Radical inverse based on http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
	uint bits = (i << 16u) | (i >> 16u);
	bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
	bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
	bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
	bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
	float rdi = float(bits) * 2.3283064365386963e-10;
	return vec2(float(i) /float(N), rdi);
}

// Based on http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_slides.pdf
vec3 importanceSample_GGX(vec2 Xi, float roughness, vec3 normal) 
{
	// Maps a 2D point to a hemisphere with spread based on roughness
	float alpha = roughness * roughness;
	float phi = 2.0 * PI * Xi.x + random(normal.xz) * 0.1;
	float cosTheta = sqrt((1.0 - Xi.y) / (1.0 + (alpha*alpha - 1.0) * Xi.y));
	float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
	vec3 H = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);

	// Tangent space
	vec3 up = abs(normal.z) < 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
	vec3 tangentX = normalize(cross(up, normal));
	vec3 tangentY = normalize(cross(normal, tangentX));

	// Convert to world Space
	return normalize(tangentX * H.x + tangentY * H.y + normal * H.z);
}

// Normal Distribution function
float D_GGX(float dotNH, float roughness)
{
	float alpha = roughness * roughness;
	float alpha2 = alpha * alpha;
	float denom = dotNH * dotNH * (alpha2 - 1.0) + 1.0;
	return (alpha2)/(PI * denom*denom); 
}


vec3 prefilterEnvMap(vec3 R, float roughness)
{
	vec3 N = R;
	vec3 V = R;
	vec3 color = vec3(0.0);
	float totalWeight = 0.0;
	float envMapDim = float(textureSize(IMAGE_CUBE[inCubeID], 0).s);

	uint samplePerMip[3] =
	{
		1,
		2048,
		4096,
	};
	uint perMipIndex = min(inMip,2);
    uint numSamples = samplePerMip[perMipIndex];
	//numSamples = min(numSamples, 2048);
	for(uint i = 0u; i < numSamples; i++) {
		vec2 Xi = hammersley2d(i, numSamples);
		vec3 H = importanceSample_GGX(Xi, roughness, N);
		vec3 L = 2.0 * dot(V, H) * H - V;
		float dotNL = clamp(dot(N, L), 0.0, 1.0);
		if(dotNL > 0.0) {
			// Filtering based on https://placeholderart.wordpress.com/2015/07/28/implementation-notes-runtime-environment-map-filtering-for-image-based-lighting/
			color += GammaToLinear(textureLod( samplerCube( IMAGE_CUBE[inCubeID], LINEAR_SAMPLER ) , L, 0 ).rgb * dotNL);
			totalWeight += dotNL;

		}
	}
	return LinearToGamma(color / totalWeight);
}


void main() {
	float miplevels = textureQueryLevels( samplerCube( IMAGE_CUBE[inCubeID], LINEAR_SAMPLER ) );
	float roughness = float(inMip) / miplevels;
	

    vec4 color0 = vec4( prefilterEnvMap( vec3( 1, inFragPos.y,-inFragPos.x ), roughness ), 1 ); // +X
    vec4 color1 = vec4( prefilterEnvMap( vec3(-1, inFragPos.y, inFragPos.x ), roughness ), 1 ); // -X
    vec4 color2 = vec4( prefilterEnvMap( vec3( inFragPos.x, 1,-inFragPos.y ), roughness ), 1 ); // +Y
    vec4 color3 = vec4( prefilterEnvMap( vec3( inFragPos.x,-1, inFragPos.y ), roughness ), 1 ); // -Y
    vec4 color4 = vec4( prefilterEnvMap( vec3( inFragPos.x, inFragPos.y, 1 ), roughness ), 1 ); // +Z
    vec4 color5 = vec4( prefilterEnvMap( vec3(-inFragPos.x, inFragPos.y,-1 ), roughness ), 1 ); // -Z
    outColor0 = color0;
    outColor1 = color1;
    outColor2 = color2;
    outColor3 = color3;
    outColor4 = color4;
    outColor5 = color5;
}