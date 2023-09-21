shader_type sky;

uniform sampler2D skyTex : source_color;

void sky() {
	COLOR.rgb = texture(skyTex, SKY_COORDS).rgb;
}
