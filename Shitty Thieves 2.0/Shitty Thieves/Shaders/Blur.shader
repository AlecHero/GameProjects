shader_type canvas_item;
uniform float blur : hint_range(1, 20, 1) = 5;

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur / 10.0);
}