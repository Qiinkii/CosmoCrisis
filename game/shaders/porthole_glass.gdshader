shader_type spatial;
// Premultiplied alpha: ALPHA controls how much of the view behind the glass
// is hidden, but the reflection is NOT dimmed by it.
render_mode blend_premul_alpha, depth_draw_opaque, cull_disabled, specular_schlick_ggx;

uniform vec4 glass_tint : source_color = vec4(0.55, 0.70, 0.85, 0.06);
uniform float glass_roughness : hint_range(0.0, 0.3) = 0.02;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.6;
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;

uniform float glare_strength : hint_range(0.0, 1.0) = 0.08;
uniform float glare_width : hint_range(0.02, 0.5) = 0.12;
uniform float glare_angle : hint_range(-1.0, 1.0) = 0.6;
uniform vec3 glare_color : source_color = vec3(0.75, 0.85, 1.0);

uniform float smudge_strength : hint_range(0.0, 0.3) = 0.03;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
        mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x),
        f.y
    );
}

void fragment() {
    vec3 n = normalize(NORMAL);
    if (!FRONT_FACING) { n = -n; }
    NORMAL = n;
    vec3 v = normalize(VIEW);

    float fres = pow(1.0 - clamp(dot(n, v), 0.0, 1.0), fresnel_power);

    vec3 r = reflect(-v, n);
    float band_pos = r.x * glare_angle + r.y * (1.0 - abs(glare_angle));
    float glare = smoothstep(glare_width, 0.0, abs(band_pos - 0.15)) * glare_strength;

    float smudge = value_noise(UV * 8.0) * value_noise(UV * 21.0 + 3.7) * smudge_strength;

    // Glass body: slightly more opaque at grazing angles
    float body_alpha = clamp(glass_tint.a + fres * 0.25 + smudge, 0.0, 1.0);

    ALPHA = body_alpha;
    ALBEDO = glass_tint.rgb * body_alpha;   // premultiplied
    METALLIC = 0.0;
    ROUGHNESS = clamp(glass_roughness + smudge * 2.0, 0.0, 1.0);
    SPECULAR = reflection_strength;         // how strong the probe reflection is
    EMISSION = glare_color * glare;
}
