shader_type canvas_item;

uniform float amount = 1.0;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float adjusted_amount = amount / 750.0;
	color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_amount, SCREEN_UV.y)).r;
	color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_amount, SCREEN_UV.y)).b;
	
	COLOR = color;
}