shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0.0, 3.0) = 0.0;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_strength);

    vec2 center_dist = SCREEN_UV - vec2(0.5);
    float dist = length(center_dist) * 1.4142;
    float inner_radius = mix(0.92, 0.28, vignette_strength);
    float outer_radius = mix(1.18, 0.78, vignette_strength);
    float vignette = smoothstep(inner_radius, outer_radius, dist);

    color.rgb *= 1.0 - vignette * vignette_strength * 0.8;
    COLOR = color;
}
