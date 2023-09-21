shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform sampler2D grassTexture : source_color, filter_nearest;
uniform vec4 grassColor : source_color;

uniform sampler2D sandTexture : source_color, filter_nearest;
uniform sampler2D dirtTexture : source_color, filter_nearest;

uniform float grassHeight;
uniform float sandHeight;

varying float height;
uniform float transition : hint_range(0.0, 1.0, 0.1);
uniform float slope_factor = 2.0;

varying vec3 normal;

void vertex(){
	NORMAL = normalize(vec3(VERTEX));
	normal = NORMAL;
	height = VERTEX.y;
}

void fragment(){
	vec2 gradient = dFdx(FRAGCOORD.xy);
    float slope = gradient.y / gradient.x;
	
	float blend_factor = smoothstep(sandHeight - 0.1, sandHeight + 0.1, height * transition);
	float blend_factor2 = smoothstep(sandHeight - 0.1, sandHeight + 0.1, height * transition);
	
	vec4 sand_tex = texture(sandTexture, UV * 16.0);
	vec4 dirt_tex = texture(dirtTexture, UV * 16.0);
	vec4 grass_tex = texture(grassTexture, UV * 16.0);
	
	vec4 final_color = mix(sand_tex, grass_tex, blend_factor);
	
	vec4 AA = mix(final_color, dirt_tex, slope * slope_factor);
	
	ALBEDO = final_color.rgb;
	
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
