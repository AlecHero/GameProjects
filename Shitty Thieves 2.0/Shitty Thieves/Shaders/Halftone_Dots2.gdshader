shader_type canvas_item;

// Halftone Shader
// Alexander Wittrup 06/06/2022
// 2D simplex noise by Ian McEwan, distributed under the MIT license.
// All other code is original but heavily inspired and occasionally
// directly converted from Stefan Gustavson's WebGL halftone shader demo:
// https://weber.itn.liu.se/~stegu/webglshadertutorial/shadertutorial.html
// And some features are inspired by Mrmo Tarius' MRMO-Halftone shader for blender
// https://mrmotarius.itch.io/mrmo-halftone

//Image pre-processing
uniform float contrast : hint_range(0, 3) = 1.0;
uniform float zoom = 0.1;
uniform float inline_ratio : hint_range(0.0, 1.0) = 0.65;
uniform float inline_feather : hint_range(0.0, 1.0) = 0.02;

//Halftone settings
uniform float offset : hint_range(-0.05, 0.05) = 0.004;
uniform float fill : hint_range(0.0, 3.0) = 1.0;
uniform float feather : hint_range(0.0, 1.5) = 0.15;
uniform float frequency : hint_range(10., 1000., 1.0) = 100.0;
uniform float noise_ratio : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float k_ratio : hint_range(0.0, 1.0, 0.01) = 1.0;

uniform bool rich_black = false;
uniform bool grayscale = false;

uniform vec4 paper_color : hint_color = vec4(1.0, 0.95, 0.84, 1.0);
uniform vec4 C : hint_color = vec4(.4, .85, .85, 1.0);
uniform vec4 M : hint_color = vec4(.85, .25, .5, 1.0);
uniform vec4 Y : hint_color = vec4(.85, .85, .2, 1.0);
uniform vec4 K : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float C_angle : hint_range(0, 360, 1.0) = 165;
uniform float M_angle : hint_range(0, 360, 1.0) = 45;
uniform float Y_angle : hint_range(0, 360, 1.0) = 90;
uniform float K_angle : hint_range(0, 360, 1.0) = 105;

uniform sampler2D halftone_pattern;

vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 mod2893(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod2893(((x * 34.0) + 1.0) * x); }
float snoise(vec2 v) {
	// (3.0-sqrt(3.0))/6.0 , 0.5*(sqrt(3.0)-1.0)
	const vec4 CC = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
	// -1.0 + 2.0 * C.x , 1.0 / 41.0
	
	// First corner
	vec2 i = floor(v + dot(v, CC.yy) );
	vec2 x0 = v - i + dot(i, CC.xx);
	// Other corners
	vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec4 x12 = x0.xyxy + CC.xxzz;
	x12.xy -= i1;
	// Permutations
	i = mod289(i); // Avoid truncation effects in permutation
	vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
	vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m *= m; m *= m;
	// Gradients
	vec3 x = 2.0 * fract(p * CC.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 a0 = x - floor(x + 0.5);
	// Normalise gradients implicitly by scaling m
	m *= 1.792843 - 0.853735 * (a0 * a0 + h * h);
	// Compute final noise value at P
	vec3 g;
	g.x = a0.x * x0.x + h.x * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	
	return 130.0 * dot(m, g);
}

float fract_noise(float fractal_i, float ratio, vec2 uv) { //Compacted way to use snoise()
	float n; for (float i = 0.0; i < fractal_i; i++) { n += ratio / (10. * pow(2.0, i)) * snoise(pow(2.0, i + 1.0) * uv); }
	return n;
}

vec2 uv_translate(float z, vec2 off, vec2 uv) {
	uv.x = uv.x * pow(2.0, z) - (pow(2.0, z) / 2.0 - off.x);
	uv.y = uv.y * pow(2.0, z) - (pow(2.0, z) / 2.0 - off.y);
	return uv;
}

vec2 rotate(vec2 uv, float r) {
	r = radians(r); //r *= (PI / 180.0); //Radians to degrees
	return uv * mat2(vec2(cos(r), sin(r)), vec2(-sin(r), cos(r)));
}

float min3(vec3 value) { return min(min(value.r, value.g), value.b); }

vec4 img_texture(sampler2D texture, vec2 uv, vec2 off) {
	vec4 image_texture = texture(texture, uv_translate(zoom, vec2(.5, .5) + off, uv)); //Blurring and scaling
	image_texture.rgb = mix(vec3(0.5), image_texture.rgb, contrast); //Contrast
	if (grayscale) image_texture.rgb = vec3(.3 * image_texture.r + .6 * image_texture.g + .1 * image_texture.b);
	
	vec2 in_uv = rotate(uv - 0.5, 45.); float r = inline_ratio;
	image_texture.rgb = mix(image_texture.rgb, vec3(1.0), smoothstep(r, inline_feather + r, abs(in_uv.x) + abs(in_uv.y)));
	return image_texture;
}

vec3 mix_mul(vec3 base, vec3 blend, float value) {
	vec3 blend_m = max(base + blend - 1.0, 0.0); //Multiplicative blend mode
	return mix(base, blend_m, value);
}

float halftone(float value, float angle, vec2 uv) {
	float n = fract_noise(4.0, noise_ratio, uv); //Fractal noise - small
	float n2 = fract_noise(1.0, noise_ratio * 0.7,  uv * 0.1); //Fractal noise - large
	return smoothstep(0.0, feather, fill * (value + n2) - texture(halftone_pattern, rotate(uv, angle)).r + n);
}

void fragment() {
	vec4 c_base = 1.0 - img_texture(SCREEN_TEXTURE, SCREEN_UV, vec2(-offset, offset));
	vec4 m_base = 1.0 - img_texture(SCREEN_TEXTURE, SCREEN_UV, vec2(offset, -offset));
	vec4 y_base = 1.0 - img_texture(SCREEN_TEXTURE, SCREEN_UV, vec2(-offset, -offset));
	vec4 k_base = 1.0 - img_texture(SCREEN_TEXTURE, SCREEN_UV, vec2(0.0, 0.0));
	
	vec4 cmyk;
	float c_k = min3(c_base.rgb) * k_ratio;
	float m_k = min3(m_base.rgb) * k_ratio;
	float y_k = min3(y_base.rgb) * k_ratio;
	
	cmyk.r = (c_base.r - c_k) / (1.0 - c_k);
	cmyk.g = (m_base.g - m_k) / (1.0 - m_k);
	cmyk.b = (y_base.b - y_k) / (1.0 - y_k);
	cmyk.a = min3(k_base.rgb) * k_ratio;
	
	vec2 uv = UV * frequency; uv.x *= 1.0 / TEXTURE_PIXEL_SIZE.x * TEXTURE_PIXEL_SIZE.y;
	vec3 color = paper_color.rgb + (fract_noise(4.0, noise_ratio, uv) / 5.0);
	color = mix_mul(color, C.rgb, halftone(cmyk.r, C_angle, uv));
	color = mix_mul(color, M.rgb, halftone(cmyk.g, M_angle, uv));
	color = mix_mul(color, Y.rgb, halftone(cmyk.b, Y_angle, uv));
	color = mix_mul(color, K.rgb, halftone(cmyk.a, K_angle, uv));
	
	COLOR.rgb = color;
}