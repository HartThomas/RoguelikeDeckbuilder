shader_type canvas_item;
render_mode unshaded;

uniform float blur_power: hint_range(0.0, 0.2, 0.001) = 0.05;
uniform sampler2D noise_texture;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 noise(vec2 uv) {
    return texture(noise_texture, uv).xy - 0.5;
}

void fragment() {
    vec2 uv = SCREEN_UV; // Use screen UV coordinates
    vec2 offset = noise(uv) * blur_power;

    // Sample screen texture with noise offset
    vec4 c = textureLod(screen_texture, uv + offset, 0.0);

    // Preserve alpha handling
    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    COLOR = c;
}
