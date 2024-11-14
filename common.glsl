

#define PI 3.1415926535897932384626433832795
#define TWO_PI PI * 2.0
#define HALF_PI PI * 0.5

// SET DEFINES
#define SAMPLERS_SET        binding = 0) uniform sampler samplers[SET_SAMPLERS_COUNT];
#define IMAGES_2D_SET       binding = 0) uniform texture2DArray sampledImages2D[SAMPLED_IMAGE_2D_COUNT];
#define IMAGES_CUBE_SET     binding = 1) uniform textureCube sampledCubeMaps[SAMPLED_CUBE_COUNT];
#define IMAGES_STORAGE_SET  binding = 2, rgba32f) uniform image2D storageImages[STORAGE_IMAGE_COUNT];
#define GLOBALS_SET         binding = 0) uniform ViewProjection { mat4 view; mat4 projection; mat4 inverseView; mat4 inverseProj; vec2 resolution; uint skyboxID; } globals;

// SET ACCESS DEFINES
#define LINEAR_SAMPLER samplers[0]
#define NEAREST_SAMPLER samplers[1]

#define IMAGE_2D        sampledImages2D
#define IMAGE_STORAGE   storageImages
#define IMAGE_CUBE      sampledCubeMaps
#define GLOBALS         globals

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