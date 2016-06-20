// Ottavio Hartman - hartmano@sas.upenn.edu

#define HASHSCALE1 .1031
#define PI 3.1415927
#define NUM_STREAKS 8.
#define STREAK_SIZE .1
#define STREAK_WIDTH .15

vec3 rgb(float r, float g, float b) {
    return vec3(r/255.0, g/255.0, b/255.0);
}
// HSV to RGB created by inigo quilez - iq/2014
vec3 hsv2rgb( in vec3 c )
{
    vec3 _rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

	return c.z * mix( vec3(1.0), _rgb, c.y);
}
// Cartesian and Polar conversions
vec2 c2p(vec2 c) {return vec2(length(c), atan(c.y, c.x));}
vec2 p2c(vec2 p) {return p.x*(vec2(cos(p.y), sin(p.y)));}

// Rand function. Credit to patriciogonzalezvivo

float rand(float n){return fract(sin(n) * 43758.5453123);}
float noise(float p){
    float fl = floor(p);
  	float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

float circle(vec2 uv, vec2 center, float radius) {
    return step(length(uv - center), radius);
}
float head(vec2 uv, vec2 center, float radius) {
    vec2 uv2 = uv - center;
    vec2 rtheta = c2p(uv2);
    float angle = rtheta.y;
    float neck = 1.*pow(angle + .2, 2.) + .65;
    float chin = .08*sin(7.*angle) + .92;
    float face = .95 + sin(angle*6.)/10.;
    uv2 = p2c(rtheta);
    if ((angle < PI/8.) && (angle > -PI/4.)) {
        uv2 /= neck;
    } else if (angle < -PI/2.) {
        uv2 /= chin;
    } else if (angle > PI/2.) {
		uv2 /= face;
    }
    uv = uv2 + center;
    float h = circle(uv, center, radius);
    return h;
}

float streak(vec2 uv, vec2 center, float radius) {
    vec2 uv_p = c2p(uv);
    vec2 center_p = c2p(center);
    // Make streaks skinny
    uv_p.y -= (center_p.y - uv_p.y)/STREAK_WIDTH;
    // Waviness
    uv_p.y += .07*noise(uv_p.x*60. + sin(uv_p.y));
    return circle(p2c(uv_p), center, radius);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 blue = rgb(2., 41., 108.);
    vec3 pale = rgb(258., 225., 179.);
    vec3 orange = rgb(245., 81., 39.);
    vec3 yellow = rgb(229., 206., 15.);
    vec3 green = rgb(132., 189., 94.);
    
    vec2 uv = fragCoord.xy / iResolution.yy;
    float maxX = iResolution.x/iResolution.y;
    
    vec2 center = vec2(.5*maxX, .5);
    vec2 rtheta = c2p(uv - center);
    float radius = PI/NUM_STREAKS;
    // Displacement away from head center
    float rand_rad = mod(rand(floor(rtheta.y/radius)) + iGlobalTime, 1.);
    rand_rad = clamp(rand_rad, .2, 1.);
    rtheta.y = mod(rtheta.y, radius) - radius/2.;
    vec2 uv2 = p2c(rtheta);
    
    float i = streak(uv2, vec2(rand_rad, 0.), STREAK_SIZE);
    
    float h = head(uv, center, .3);
    
    // Not sure if this is best way to do layers
    vec3 pixel = vec3(0.0);
    vec3 color = rgb(245., 81., 39.);
    if (i != 0.0) {
        pixel = hsv2rgb(vec3(rand_rad, .73, .9));
    } else if (h != 0.0) {
        pixel = pale * h;
    }
    
    fragColor = vec4(pixel, 1.0);
}
