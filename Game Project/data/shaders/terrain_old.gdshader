shader_type spatial;

uniform float max_grass_height = 2.0;
uniform float min_snow_height = 18.0;
uniform float slope_factor = 8.0;

uniform sampler2D grass_perlin;
uniform sampler2D grass_perlin2;
uniform float grassPForce = 0;
uniform vec2 grassScale;
uniform vec4 grassGradient : source_color;

uniform sampler2D grass_tex : source_color, filter_nearest;
uniform vec2 grass_scale;

uniform sampler2D grass_tex_2 : source_color, filter_nearest;
uniform vec2 grass_scale_2;

uniform sampler2D dirt_tex : source_color, filter_nearest;
uniform vec2 dirt_scale;

uniform sampler2D snow_tex : source_color, filter_nearest;
uniform vec2 snow_scale;

uniform sampler2D sand_tex : source_color, filter_nearest;
uniform vec2 sand_scale;

varying float height_val;
varying vec3 normal;

uniform float min_sand_height = 1.0;
uniform float max_sand_height = -2.5;

uniform sampler2D sandGradient : source_color;

void vertex(){
	height_val = VERTEX.y;
	normal = NORMAL;
}

float get_slope_of_terrain(float height_normal){
	float slope = 1.0-height_normal;
	slope *= slope;
	return (slope * slope_factor);
}

float get_snow_and_grass_mix(float curr_height){
	if (curr_height > min_snow_height){
		return 1.0;
	}
	if (curr_height  < max_grass_height){
		return 0.0;
	}
	float mix_height = (curr_height-max_grass_height) / (min_snow_height-max_grass_height);
	return mix_height;
}

float get_sand_and_grass_mix(float curr_height){
	if (curr_height > min_sand_height){
		return 1.0;
	}
	if (curr_height  < max_grass_height){
		return 0.0;
	}
	float mix_height = (curr_height-max_grass_height) / (min_sand_height-max_grass_height);
	return mix_height;
}

void fragment(){
	vec3 dirt = vec3(texture(dirt_tex, UV*dirt_scale).rgb)*0.35;
	
	vec3 grass = vec3(texture(grass_tex, UV * grass_scale).rgb) * grassGradient.rgb;
	vec3 grass_2 = vec3(texture(grass_tex_2, UV * grass_scale_2).rgb);
	vec3 snow = vec3(texture(snow_tex, UV*snow_scale).rgb);
	vec3 sand = vec3(texture(sand_tex, UV * grass_scale).rgb);
	
	vec4 pGrass = texture(grass_perlin, UV * grassScale);
	vec4 pGrass2 = texture(grass_perlin2, UV * grassScale);
	
	float rp = pGrass.r * grassPForce;
	
	grass = mix(grass, grass_2, rp);
	grass = mix(grass, grass + grassGradient.rgb, pGrass2.r);
	
	float slope = clamp(get_slope_of_terrain(normal.y), 0.0, 1.0);
	float snow_mix = clamp(get_snow_and_grass_mix(height_val), 0.0, 1.0);
	
	vec3 grass_mixin = mix(grass, dirt, slope);
	vec3 dirt_mixin = mix(dirt, snow, snow_mix/slope);
	vec3 snow_mixin = mix(snow, dirt_mixin, slope);
	
	vec3 mixin = mix(grass_mixin, snow_mixin, snow_mix);
	
	if(height_val < max_sand_height){
		mixin = mix(grass_mixin, sand, 1.0);
	}
	
	ALBEDO = mixin;
}