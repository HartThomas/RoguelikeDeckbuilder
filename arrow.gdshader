shader_type canvas_item;

uniform vec4 outline_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_width = 3.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float alpha = tex.a;

    float outline = 0.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * (outline_width / 100.0);
            outline = max(outline, texture(TEXTURE, UV + offset).a);
        }
    }

    vec4 outline_col = outline_color * outline;
    COLOR = mix(outline_col, tex, alpha);
}