shader_type canvas_item;

uniform vec3 pop_colour : source_color = vec3(1.0);
uniform float radius : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float softness : hint_range(0.001, 0.5, 0.01) = 0.0;
uniform float fade : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(uv, center);

	// Calculate glow mask
	float glow = 1.0 - smoothstep(radius, radius + softness, dist);

	// Texture color
	vec4 tex_color = texture(TEXTURE, uv);

	// Color when fully glowing
	vec3 glow_color = mix(tex_color.rgb, pop_colour, glow);

	// Interpolate from glow back to original texture based on fade value
	vec3 final_color = mix(glow_color, tex_color.rgb, fade);

	COLOR = vec4(final_color, tex_color.a);
}