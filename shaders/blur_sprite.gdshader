shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D texture_albedo;
uniform sampler2D noise_texture;
uniform float glow_smoothness : hint_range(0.01, 1.0) = 0.2;
uniform float blur_power: hint_range(0.0, 0.2) = 0.05;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 10.0, 0.1) = 5.0;
uniform float glow_radius : hint_range(0.0, 0.2) = 0.05;
uniform bool hovered = false;

vec2 noise(vec2 uv) {
    return texture(noise_texture, uv).xy - 0.5;
}

float sample_alpha(vec2 uv) {
    return texture(texture_albedo, uv).a;
}

float compute_inner_edge_falloff(vec2 uv) {
    float center_alpha = sample_alpha(uv);
    if (center_alpha < 0.01) return 0.0;

    float min_alpha = center_alpha;
    float max_distance = glow_radius;
    int steps = 8;

    for (int i = 0; i < steps; i++) {
        float angle = 6.283185 * float(i) / float(steps);
        vec2 dir = vec2(cos(angle), sin(angle));

        for (int j = 1; j <= 4; j++) {
            float dist = max_distance * float(j) / 4.0;
            vec2 offset = dir * dist;
            float sampled = sample_alpha(uv + offset);
            min_alpha = min(min_alpha, sampled);
        }
    }

    // Difference in alpha between center and outer points
    float alpha_diff = center_alpha - min_alpha;

    // DEBUG: Try showing just this difference visually
     //COLOR = vec4(vec3(alpha_diff), 1.0);

    float edge_factor = smoothstep(0.0, glow_smoothness, alpha_diff);
    return edge_factor;
}

void fragment() {
    vec2 uv = UV;

    // Apply blur using noise
    vec2 offset = noise(uv) * blur_power;
    vec4 base_color = texture(texture_albedo, uv + offset);

    // Inner edge glow
    float glow_falloff = compute_inner_edge_falloff(uv);
    float glow = glow_falloff * glow_strength;

    vec4 glow_effect = vec4(glow_color.rgb * glow, glow_color.a * glow);

    COLOR = base_color;
    if (hovered) {
        COLOR += glow_effect;
    }

    COLOR.a *= base_color.a;
}
