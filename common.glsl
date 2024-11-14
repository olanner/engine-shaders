


#define PI 3.1415926535897932384626433832795
#define TWO_PI PI * 2.0
#define HALF_PI PI * 0.5

//layout (set = SET_SAMPLERS, binding = 0)        uniform sampler samplers[SET_SAMPLERS_COUNT];
//layout (set = SET_IMAGES, binding = 0)          uniform texture2D sampledImages[SAMPLED_IMAGE_COUNT];
//layout (set = SET_IMAGES, binding = 1, rgba32f) uniform image2D storageImages[STORAGE_IMAGE_COUNT];
//
//layout (set = SET_IMAGES, binding = 2)          uniform textureCube sampledCubeMaps[SAMPLED_CUBE_COUNT];
//
//layout(set = SET_GLOBALS, binding = 0)          uniform ViewProjection { mat4 view; mat4 projection; mat4 inverseView; mat4 inverseProj; } uniVP;

// SET DEFINES
#define SAMPLERS_SET        binding = 0) uniform sampler samplers[SET_SAMPLERS_COUNT];
#define IMAGES_2D_SET       binding = 0) uniform texture2DArray sampledImages2D[SAMPLED_IMAGE_2D_COUNT];
#define IMAGES_CUBE_SET     binding = 1) uniform textureCube sampledCubeMaps[SAMPLED_CUBE_COUNT];
#define IMAGES_STORAGE_SET  binding = 2, rgba32f) uniform image2D storageImages[STORAGE_IMAGE_COUNT];
#define GLOBALS_SET         binding = 0) uniform ViewProjection { mat4 view; mat4 projection; mat4 inverseView; mat4 inverseProj; vec2 resolution; uint skyboxID; } globals;
//#define FONTS_SET           binding = 0) uniform sampler2DArray sampledFonts[FONTS_COUNT];

// SET ACCESS DEFINES
#define LINEAR_SAMPLER samplers[0]
#define NEAREST_SAMPLER samplers[1]

#define IMAGE_2D        sampledImages2D
#define IMAGE_STORAGE   storageImages
#define IMAGE_CUBE      sampledCubeMaps
#define GLOBALS         globals

//vec4 FetchSampledImage(uint imgID, vec2 uv)
//{
//   return texture( sampler2D(sampledImages[imgID], samplers[0]), uv);
//}
//vec4 FetchCubeMap(uint cubeID, vec3 uv)
//{
//   return texture( samplerCube(sampledCubeMaps[cubeID], samplers[0]), uv);
//}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

highp float rand(vec2 co)
{
    highp float a  = 12.9898;
    highp float b  = 78.233;
    highp float c  = 43758.5453;
    highp float dt = dot(co.xy ,vec2(a,b));
    highp float sn = mod(dt,3.14);
    return fract(sin(sn) * c);
}

vec2 encode(vec3 n, vec3 view)
{
  vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
  enc = enc*0.5+0.5;
  return enc;
}

vec3 decode(vec4 enc, vec3 view)
{
  vec4 nn = enc*vec4(2,2,0,0) + vec4(-1,-1,1,-1);
  float l  = dot(nn.xyz,-nn.xyw);
  nn.z    = l;
  nn.xy   *= sqrt(l);
  return nn.xyz * 2 + vec3(0,0,-1);
}

// mat4 inverse(mat4 m)
// {
//     float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
//     float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
//     float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
//     float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

//     float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
//     float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
//     float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
//     float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

//     float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
//     float idet = 1.0f / det;

//     mat4 ret;

//     ret[0][0] = t11 * idet;
//     ret[0][1] = ( n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44 ) * idet;
//     ret[0][2] = ( n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44 ) * idet;
//     ret[0][3] = ( n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43 ) * idet;

//     ret[1][0] = t12 * idet;
//     ret[1][1] = ( n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44 ) * idet;
//     ret[1][2] = ( n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44 ) * idet;
//     ret[1][3] = ( n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43 ) * idet;

//     ret[2][0] = t13 * idet;
//     ret[2][1] = ( n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44 ) * idet;
//     ret[2][2] = ( n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44 ) * idet;
//     ret[2][3] = ( n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43 ) * idet;

//     ret[3][0] = t14 * idet;
//     ret[3][1] = ( n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34 ) * idet;
//     ret[3][2] = ( n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34 ) * idet;
//     ret[3][3] = ( n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33 ) * idet;

//     return ret;
// }