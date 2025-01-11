shader_type canvas_item;

uniform float hdr_threshold = 5.0;
uniform float exposure = 0.6;
uniform float blur_size = 4.0;
uniform float glow_intensity = 0.5;
uniform float overlay_number = 0.4;

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(1.0, base);
	return mix(2.0 * base * blend, (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)) * overlay_number, limit);
	//https://godotshaders.com/snippet/blending-modes/
}

vec4 sample_glow_pixel(sampler2D tex, vec2 uv) {
	return max((textureLod(tex, uv, blur_size) - hdr_threshold) * exposure, vec4(0.0));
}

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec4 bloom = vec4(0.0);
	
	// Get blurred color from pixels considered glowing
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0));
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0));
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, -ps.y));
	bloom += sample_glow_pixel(SCREEN_TEXTURE, SCREEN_UV + vec2(0, ps.y));
	
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 glowing_col = glow_intensity * bloom;
	
	col.rgb += glowing_col.rgb;
	
	//COLOR = vec4(col.rgb + glowing_col.rgb, col.a);
	COLOR = overlay(col, COLOR);
}



//uniform float bloomRadius = 2.70;
//uniform float bloomThreshold = 0.37;
//uniform float bloomIntensity = 1.35;
//
//vec3 GetBloomPixel(sampler2D tex, vec2 uv, vec2 texPixelSize) {
//	vec2 uv2 = floor(uv / texPixelSize) * texPixelSize + texPixelSize * .001;
//	vec2 f = fract( uv / texPixelSize );
//
//	vec3 tl = max(texture(tex, uv2).rgb - bloomThreshold, 0.0);
//	vec3 tr = max(texture(tex, uv2 + vec2(texPixelSize.x, 0.0)).rgb - bloomThreshold, 0.0);
//	vec3 tA = mix( tl, tr, f.x );
//
//	vec3 bl = max(texture(tex, uv2 + vec2(0.0, texPixelSize.y)).rgb - bloomThreshold, 0.0);
//	vec3 br = max(texture(tex, uv2 + vec2(texPixelSize.x, texPixelSize.y)).rgb - bloomThreshold, 0.0);
//	vec3 tB = mix( bl, br, f.x );
//
//	return mix( tA, tB, f.y );
//}
//
//vec3 GetBloom(sampler2D tex, vec2 uv, vec2 texPixelSize) {
//	vec3 bloom = vec3(0.0);
//	vec2 off = vec2(1) * texPixelSize * bloomRadius;
//	bloom += GetBloomPixel(tex, uv + off * vec2(-1, -1), texPixelSize) * 0.292893;
//	bloom += GetBloomPixel(tex, uv + off * vec2(-1, 0), texPixelSize) * 0.5;
//	bloom += GetBloomPixel(tex, uv + off * vec2(-1, 1), texPixelSize) * 0.292893;
//	bloom += GetBloomPixel(tex, uv + off * vec2(0, -1), texPixelSize) * 0.5;
//	bloom += GetBloomPixel(tex, uv + off * vec2(0, 0), texPixelSize) * 1.0;
//	bloom += GetBloomPixel(tex, uv + off * vec2(0, 1), texPixelSize) * 0.5;
//	bloom += GetBloomPixel(tex, uv + off * vec2(1, -1), texPixelSize) * 0.292893;
//	bloom += GetBloomPixel(tex, uv + off * vec2(1, 0), texPixelSize) * 0.5;
//	bloom += GetBloomPixel(tex, uv + off * vec2(1, 1), texPixelSize) * 0.292893;
//	bloom /= 4.171573f;
//	return bloom;
//}
//
//void fragment() {
//	//vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
//	vec4 col = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
//	vec3 bloom = GetBloom(SCREEN_TEXTURE, SCREEN_UV, TEXTURE_PIXEL_SIZE);
//	col.rgb += bloom * bloomIntensity;
//	COLOR = col;
//}