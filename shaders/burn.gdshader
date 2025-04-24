shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise_texture : hint_default_black, repeat_enable;
uniform float burn_amount : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec3 burn_colour : source_color = vec3(0.8, 0.4, 0.2);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 uv = UV;
	vec3 base_color = texture(TEXTURE, uv).rgb;
	float burn_pixel = texture(noise_texture, uv).r;

	// Smooth transition area
	float mask = smoothstep(1.0 - burn_amount - 0.1, 1.0 - burn_amount, burn_pixel);

	// If burn_amount is 0, don't burn or tint at all
	if (burn_amount <= 0.0) {
		COLOR = texture(TEXTURE, uv);
	} else {
		// Fade out alpha where burn happens
		float alpha = 1.0 - mask;

		// Optional: Tint the edges a bit where burn is strongest
		vec3 color = mix(base_color, base_color * burn_colour, mask * 0.5);

		COLOR = vec4(color, alpha);
	}

	// Multiply with screen texture
	vec4 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (screen_color.a > 0.0001) {
		screen_color.rgb /= screen_color.a;
	}

	COLOR *= screen_color;
}
