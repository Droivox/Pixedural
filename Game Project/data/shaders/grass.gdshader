shader_type spatial;

uniform sampler2D grass;

void fragment() {
	vec4 grassV4 = texture(grass, UV);
	ALBEDO.rgb = grassV4.rgb;
	
	ALPHA = grassV4;
}
