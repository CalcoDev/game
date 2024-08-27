shader_type canvas_item;

uniform float u_height = 0.0;
uniform float u_hover = 0.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
    COLOR = vec4(u_height, u_hover, 0.0, col.a);
}
