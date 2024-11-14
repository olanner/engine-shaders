#version 460
#extension GL_ARB_separate_shader_objects : enable

layout(location = 0) in vec3 inFragPos;
layout(location = 1) in vec3 inViewDir;

layout(location = 0) out vec4 outColor;

#extension GL_GOOGLE_include_directive : enable
#include "Shaders/common.glsl"
#include "Shaders/pbr_functions.glsl"

layout (set = 0, GLOBALS_SET;
layout (set = 1, SAMPLERS_SET;
layout (set = 2, IMAGES_CUBE_SET;
layout (set = 2, IMAGES_2D_SET;


layout (input_attachment_index = 0, set = 3, binding = 0) uniform subpassInput gBuffer[4];
//layout (input_attachment_index = 1, set = 3, binding = 0) uniform subpassInput attNormal;
//layout (input_attachment_index = 3, set = 3, binding = 0) uniform subpassInput attWorldPos;
//layout (input_attachment_index = 4, set = 3, binding = 0) uniform subpassInput attMaterial;

void main() {

    float mipLevels = textureQueryLevels( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ));

    vec3 albedo = GammaToLinear(subpassLoad(gBuffer[0]).xyz);
    bool isVoid = !bool(subpassLoad(gBuffer[0]).w);
    if(isVoid)
    {
        outColor = 
            vec4( textureLod(samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), inViewDir,0).xyz, 1 );
        return;
    }

    vec3 worldPos = subpassLoad(gBuffer[1]).xyz;
	vec3 V = normalize(GLOBALS.inverseView[3].xyz - worldPos);

    vec4 tangent = vec4(0);
    vec4 normal = tangent = (subpassLoad(gBuffer[2]));
    normal.zw = vec2(0);
    tangent.xy = tangent.zw;
    tangent.zw = vec2(0);

    vec3 N = normalize(decode(normal, V));
    vec3 T = normalize(decode(tangent, V));
    vec3 H = normalize(V + N);

	vec3 R = reflect(-V, N); 

    vec4 material = subpassLoad(gBuffer[3]);
	float metallic = material.y;
	float roughness = material.x;

	vec3 F0 = vec3(0.04); 
	F0 = mix(F0, albedo, metallic);
    float UVdotNV = max(dot(N, V), 0.0);
	vec2 brdf = 
        textureLod( sampler2DArray(IMAGE_2D[0], NEAREST_SAMPLER), vec3(UVdotNV, roughness, 0), 0).rg;
	vec3 reflection = 
        GammaToLinear( textureLod( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), R, (mipLevels - 1) * roughness ).xyz ); // MAJOR DIFF A
	vec3 irradiance = 
        GammaToLinear( textureLod( samplerCube( IMAGE_CUBE[GLOBALS.skyboxID], LINEAR_SAMPLER ), N.xyz, mipLevels - 1 ).xyz ); // MAJOR DIFF B
	// Diffuse based on irradiance
	vec3 diffuse = irradiance * albedo;	

	vec3 F = max( F_SchlickR(max(dot(N, V), 0.0), F0, roughness), 0 );
    //F = F_Schlick(max(dot(N, V), 0.0), metallic, albedo);

	// Specular reflectance
	vec3 specular = reflection * (F * brdf.x + brdf.y);

	// Ambient part
	vec3 kD = 1.0 - F0;
	kD *= 1.0 - metallic;	  
	vec3 ambient = (kD * diffuse + specular);
	
	vec3 color = ambient;

	// Gamma correction
    //color = ACESFilm(color);
	color = LinearToGamma(color);

	outColor = vec4(color, 1.0);
}