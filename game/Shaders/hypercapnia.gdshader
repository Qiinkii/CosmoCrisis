shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_strength : hint_range(0.0, 5.0) = 0.0;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE * blur_strength * 2.5;
	vec4 color = texture(screen_texture, SCREEN_UV) * 0.2;

	color += texture(screen_texture, SCREEN_UV + vec2(pixel_size.x, 0.0)) * 0.1;
	color += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x, 0.0)) * 0.1;
	color += texture(screen_texture, SCREEN_UV + vec2(0.0, pixel_size.y)) * 0.1;
	color += texture(screen_texture, SCREEN_UV + vec2(0.0, -pixel_size.y)) * 0.1;
	color += texture(screen_texture, SCREEN_UV + pixel_size * 0.707) * 0.1;
	color += texture(screen_texture, SCREEN_UV - pixel_size * 0.707) * 0.1;
	color += texture(screen_texture, SCREEN_UV + vec2(pixel_size.x, -pixel_size.y) * 0.707) * 0.1;
	color += texture(screen_texture, SCREEN_UV + vec2(-pixel_size.x, pixel_size.y) * 0.707) * 0.1;

	vec2 center_dist = SCREEN_UV - vec2(0.5);
	float dist = length(center_dist) * 1.4142;
	float inner_radius = mix(0.85, 0.22, vignette_strength);
	float outer_radius = mix(1.15, 0.65, vignette_strength);
	float vignette = smoothstep(inner_radius, outer_radius, dist);

	color.rgb *= (1.0 - vignette * vignette_strength * 0.95);
	COLOR = color;
}