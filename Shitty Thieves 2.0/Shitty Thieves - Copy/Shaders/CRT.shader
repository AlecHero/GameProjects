shader_type canvas_item;

uniform float scan_line_count : hint_range(0, 1080) = 225.0;
uniform float scan_line_contrast : hint_range(0.1, 1.0, 0.1) = 0.5;
uniform float scan_line_thickness : hint_range(0.1, 1.5, 0.05) = 0.25;

uniform float horizontal_curve : hint_range(1.0, 5.0, 0.25) = 4.0;
uniform float vertical_curve : hint_range(1.0, 5.0, 0.25) = 3.0;

vec2 uv_curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv.x *= 1.0 + pow(abs(uv.y) / horizontal_curve, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / vertical_curve, 2.0);
	uv = (uv / 2.0) + 0.5;
	return uv;
}

void fragment() {
	float s = sin(uv_curve(SCREEN_UV).y * scan_line_count * 3.14159 * 2.0);
	s = pow(s * scan_line_contrast + 0.6, scan_line_thickness);
	vec4 scan_line = vec4(vec3(s), 1.0);
	COLOR = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV), 1.0) * scan_line;
}