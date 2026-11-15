shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float heat_haze_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    float slow_wave = sin(uv.y * 34.0 + TIME * 2.8 + sin(uv.y * 8.0 - TIME * 0.7) * 1.4);
    float fine_wave = sin(uv.y * 78.0 - TIME * 4.2 + sin(uv.x * 11.0 + TIME) * 0.8);
    float horizontal_flow = sin(uv.x * 22.0 + TIME * 1.7 + uv.y * 13.0);

    // Small animated modulation keeps the heat shimmer from looking perfectly uniform.
    float variation = 0.85 + 0.15 * sin(TIME * 0.9 + uv.x * 7.0 + uv.y * 5.0);
    float shimmer = heat_haze_strength * variation;
    uv.x += (slow_wave * 0.0010 + fine_wave * 0.00035) * shimmer;
    uv.y += horizontal_flow * 0.0003 * shimmer;
    uv = clamp(uv, vec2(0.001), vec2(0.999));

    vec4 color = textureLod(screen_texture, uv, 0.0);
    // Gradually add a noticeable but restrained red cast as temperature rises.
    float red_tint = heat_haze_strength * (0.10 + 0.08 * variation);
    color.rgb = mix(color.rgb, color.rgb * vec3(1.12, 0.90, 0.89), red_tint);
    COLOR = color;
}
