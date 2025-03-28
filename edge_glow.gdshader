shader_type canvas_item;
render_mode blend_mix;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 10.0, 0.1) = 5.0;
uniform float edge_width : hint_range(0.0, 0.5) = 0.2;
uniform bool hovered = false;


void fragment() {
	vec2 uv = UV;
    
    // Calculate distance to nearest edge
    float edge_dist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));

    // Create smooth glow effect
    float glow = smoothstep(edge_width, 0.0, edge_dist) * glow_strength;
    
    
    vec4 glow_effect = vec4(glow_color.rgb * glow, glow_color.a * clamp(glow, 0.0, 1.0));

    // Apply only if hovered, otherwise fully transparent
    if (hovered) {
        COLOR = glow_effect;
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Fully transparent
    }
}

