shader_type spatial;
render_mode depth_draw_opaque, depth_prepass_alpha;

uniform sampler2D fish : source_color, filter_nearest, hint_default_transparent;
render_mode cull_disabled;

uniform float range : hint_range(0.0, 5.0, 0.01) = 0.1;
uniform float speed : hint_range(0.0, 5.0, 0.01) = 2.0;

uniform sampler2D perlinNoise;

void vertex(){
	float perlin = texture(perlinNoise, UV + vec2(-mod(TIME, 1.0), 0.0)).r;
	VERTEX.z += (perlin * speed) * range;
	VERTEX.x += ((perlin * speed) * range) / 2.0;
	VERTEX.z -= (speed * range) / 2.0;
}

void fragment() {
	ALBEDO = texture(fish, UV).rgb;
	ALPHA = texture(fish, UV).a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
