shader_type canvas_item;
uniform float overlay_number : hint_range(0.05, 1.0, 0.05) = 0.5;

vec4 overlay(vec4 base, vec4 blend) {
	return mix(2.0 * base * blend, (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)) * overlay_number, base);
	//https://godotshaders.com/snippet/blending-modes/
}

float rand(vec2 coord){
	// prevents randomness decreasing from coordinates too large
	coord = mod(coord, 10.0);
	// returns "random" float between 0 and 1
	return fract(sin(dot(coord, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 coord = UV * 10.0;
	COLOR.r = rand(coord * TIME + 0.0);
	COLOR.g = rand(coord * TIME + 1.0);
	COLOR.b = rand(coord * TIME + 2.0);
	COLOR = overlay(texture(SCREEN_TEXTURE, SCREEN_UV), COLOR);
}