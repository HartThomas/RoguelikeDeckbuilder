shader_type canvas_item;

uniform float fov : hint_range(1.0, 179.0) = 60.0;
uniform float x_rot : hint_range(-180.0, 180.0) = 0.0;
uniform float y_rot : hint_range(-180.0, 180.0) = 0.0;
uniform float inset : hint_range(0.0, 1.0) = 0.0;

uniform vec2 mouse_screen_pos = vec2(0.0, 0.0);
uniform float hovering;
uniform float rand_trans_power = 1.0;
uniform float rand_seed;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform float width : hint_range(0.0, 10.0) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // 0=diamond, 1=circle, 2=square
uniform bool inside = false;

varying mat3 inv_rot_mat;
varying vec2 pivot;
varying vec2 region_rate;

void vertex() {
	vec2 my_region_rate = abs(VERTEX) * 2.0;
	region_rate = TEXTURE_PIXEL_SIZE * my_region_rate;

	if (VERTEX_ID == 0) pivot = UV;
	else if (VERTEX_ID == 1) pivot = UV - vec2(0.0, region_rate.y);
	else if (VERTEX_ID == 2) pivot = UV - vec2(region_rate.x, region_rate.y);
	else if (VERTEX_ID == 3) pivot = UV - vec2(region_rate.x, 0.0);

	float rand_angle = rand_trans_power * mod((TIME + rand_seed * 10.0) * (0.9 + mod(rand_seed, 1.0)), 2.0 * PI);
	vec2 rand_vec = vec2(cos(rand_angle), sin(rand_angle));
	vec2 canvas_mouse = (inverse(MODEL_MATRIX) * vec4(mouse_screen_pos, 0.0, 1.0)).xy;
	vec2 mouse_force = hovering * 0.5 * (canvas_mouse) / length(region_rate / TEXTURE_PIXEL_SIZE) + rand_vec * 0.05 * rand_trans_power;

	float sin_b = sin(y_rot / 180.0 * PI + mouse_force.x);
	float cos_b = cos(y_rot / 180.0 * PI + mouse_force.x);
	float sin_c = sin(x_rot / 180.0 * PI - mouse_force.y);
	float cos_c = cos(x_rot / 180.0 * PI - mouse_force.y);

	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;

	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;

	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;

	vec2 uv = (UV - pivot) / region_rate;
	float t = tan(fov / 360.0 * PI);
	VERTEX += (uv - 0.5) * my_region_rate * t * (1.0 - inset);
}

bool hasContraryNeighbour(vec2 uv, vec2 texel_size, sampler2D tex) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		if (pattern == 0) {
			offset = width - abs(x); // diamond
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2.0) - x * x)); // circle
		} else {
			offset = width; // square
		}
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 neighbor_uv = uv + texel_size * vec2(x, y);
			if ((neighbor_uv != clamp(neighbor_uv, vec2(0.0), vec2(1.0)) || texture(tex, neighbor_uv).a == 0.0) == inside) {
				return true;
			}
		}
	}
	return false;
}

void fragment() {
	vec2 uv = (UV - pivot) / region_rate;
	float t = tan(radians(fov) / 2.0);

	vec3 p = inv_rot_mat * vec3(uv - 0.5, 0.5 / t);
	float v = (0.5 / t) + 0.5;
	p.xy *= v * inv_rot_mat[2].z;
	vec2 o = v * inv_rot_mat[2].xy;
	uv = (p.xy / p.z) - o + 0.5;

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) discard;

	uv = pivot + uv * region_rate;
	uv = clamp(uv, vec2(0.0), vec2(1.0));
	vec4 tex_color = texture(TEXTURE, uv);

	bool outline = hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE);
	if ((tex_color.a > 0.0) == inside && outline) {
		tex_color.rgb = inside ? mix(tex_color.rgb, outline_color.rgb, outline_color.a) : outline_color.rgb;
		tex_color.a += (1.0 - tex_color.a) * outline_color.a;
	}

	COLOR = tex_color;
}
