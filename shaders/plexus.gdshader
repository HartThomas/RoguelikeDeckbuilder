shader_type canvas_item;

uniform vec2 resolution = vec2(600.0, 400.0);
uniform vec3 line_color: source_color = vec3(0.1,0.4,0.2);
uniform int octaves: hint_range(1, 50, 1) = 20;
uniform float zoom_factor: hint_range(1.0, 100.0, 0.1) = 10.0;
uniform float zoom_coef:hint_range(1.0, 5.0, 0.01) = 1.1;
uniform float brightness:hint_range(1.0, 100.0, 0.1) = 10.0;
uniform float rotation_angle: hint_range(0.0, 4.0, 0.01) = 0.5;

mat2 rotate(float angle) {
	float sa = sin(angle);
	float ca = cos(angle);
	return mat2(vec2(ca,sa), vec2(-sa, ca));
}

vec2 fractal(vec2 uv, float time) {
	vec2 shift = vec2(0.0);
	vec2 warped_uv = vec2(0.0);
	vec2 fbm = vec2(0.0);
	float zoom = zoom_factor;
	mat2 rotation = rotate(rotation_angle);
	for (int i =0; i< octaves; i++){
		uv *= rotation;
		shift *= rotation;
		warped_uv = uv * zoom + float(i) + shift + time;
		shift += sin(warped_uv);
		fbm += cos(warped_uv) / zoom;
		zoom *= zoom_coef;
	}
	return fbm;
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	float time = TIME;
	vec2 fbm = fractal(uv, time);
	vec3 color = brightness * line_color * pow(fbm.x +fbm.y + 0.001/length(fbm), 2.0);
	COLOR = vec4(color, 1.0);
}

