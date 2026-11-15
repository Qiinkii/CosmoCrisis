shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float heat_haze_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    float slow_wave = sin(uv.y * 34.0 + TIME * 2.8 + sin(uv.y * 8.0 - TIME * 0.7) * 1.4);
    float fine_wave = sin(uv.y * 78.0 - TIME * 4.2 + sin(uv.x * 11.0 + TIME) * 0.8);
    float horizontal_flow = sin(uv.x * 22.0 + TIME * 1.7 + uv.y * 13.0);

    // Keep the refraction subtle so the heat shimmer doesn't dominate the scene.
    uv.x += (slow_wave * 0.0010 + fine_wave * 0.00035) * heat_haze_strength;
    uv.y += horizontal_flow * 0.0003 * heat_haze_strength;
    uv = clamp(uv, vec2(0.001), vec2(0.999));

    vec4 color = textureLod(screen_texture, uv, 0.0);
    // Add a restrained red-warm cast that grows with the heat haze.
    color.rgb = mix(color.rgb, color.rgb * vec3(1.04, 0.98, 0.97), heat_haze_strength * 0.22);
    COLOR = color;
}
