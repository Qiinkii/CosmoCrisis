shader_type sky;

uniform vec3 space_color : source_color = vec3(0.001, 0.002, 0.006);
uniform vec3 nebula_color : source_color = vec3(0.006, 0.010, 0.026);
uniform float star_brightness : hint_range(1.0, 8.0) = 4.0;
uniform float star_density : hint_range(0.0, 1.0) = 0.05;

// Glimmering / color-cycling stars
uniform float special_fraction : hint_range(0.0, 0.5) = 0.12;
uniform float super_fraction : hint_range(0.0, 0.5) = 0.03;   // extra-strong glimmer stars
uniform float glimmer_strength : hint_range(0.0, 8.0) = 3.5;
uniform float spike_length : hint_range(0.05, 0.5) = 0.28;
uniform float color_cycle_speed : hint_range(0.0, 1.0) = 0.22;
uniform float color_saturation : hint_range(0.0, 1.0) = 1.0;  // 1.0 = vivid, lower = pastel

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Wide star color palette: red, orange, yellow, white, blue, violet
vec3 star_palette(float t) {
    vec3 c0 = vec3(1.00, 0.35, 0.25); // red
    vec3 c1 = vec3(1.00, 0.62, 0.30); // orange
    vec3 c2 = vec3(1.00, 0.92, 0.55); // yellow
    vec3 c3 = vec3(1.00, 1.00, 1.00); // white
    vec3 c4 = vec3(0.55, 0.78, 1.00); // blue
    vec3 c5 = vec3(0.70, 0.55, 1.00); // violet
    float x = clamp(t, 0.0, 0.9999) * 5.0;
    float i = floor(x);
    float f = fract(x);
    vec3 a = c0; vec3 b = c1;
    if (i == 1.0) { a = c1; b = c2; }
    else if (i == 2.0) { a = c2; b = c3; }
    else if (i == 3.0) { a = c3; b = c4; }
    else if (i == 4.0) { a = c4; b = c5; }
    return mix(a, b, f);
}

void sky() {
    vec3 direction = normalize(EYEDIR);
    vec2 uv = vec2(
        atan(direction.z, direction.x) / TAU + 0.5,
        asin(clamp(direction.y, -1.0, 1.0)) / PI + 0.5
    );

    float haze = smoothstep(-0.45, 0.8, sin(uv.x * TAU + sin(uv.y * 5.0)) * cos(uv.y * 7.0));
    vec3 background_color = mix(space_color, nebula_color, haze * 0.25);

    vec2 grid = uv * vec2(300.0, 150.0);
    vec2 cell = floor(grid);
    vec2 cell_uv = fract(grid);
    float star_chance = hash21(cell);
    vec2 star_uv = 0.15 + 0.7 * vec2(hash21(cell + 17.17), hash21(cell + 43.71));
    float size_seed = hash21(cell + 79.31);
    float star_radius = mix(0.018, 0.055, size_seed);

    vec2 d = cell_uv - star_uv;
    float star_distance = length(d);

    float is_star = step(1.0 - star_density, star_chance);
    float special_roll = hash21(cell + 307.7);
    float is_special = is_star * step(1.0 - special_fraction, special_roll);
    float is_super = is_star * step(1.0 - super_fraction, special_roll); // subset of special

    // Sharp periodic pulse, unique speed and phase per star
    float pulse_speed = mix(0.7, 2.0, hash21(cell + 321.3));
    float pulse_phase = hash21(cell + 333.9) * TAU;
    float pulse = pow(0.5 + 0.5 * sin(TIME * pulse_speed + pulse_phase), 3.0);

    // Core and halo grow while the star pulses (super stars flare bigger)
    float radius_boost = 1.0 + is_special * pulse * 0.9 + is_super * pulse * 0.8;
    float r = star_radius * radius_boost;
    float star_core = 1.0 - smoothstep(r * 0.25, r, star_distance);
    float star_halo = 1.0 - smoothstep(r, r + 0.055, star_distance);
    float star_mask = is_star * (star_core + star_halo * 0.18);
    star_mask *= 1.0 + is_special * pulse * 1.8 + is_super * pulse * 2.0;

    // Cross spikes (horizontal + vertical), longer and brighter than before
    float len = spike_length * (1.0 + is_super * 0.8);
    float spike_h = max(0.0, 1.0 - abs(d.x) / len) * exp(-abs(d.y) * 60.0);
    float spike_v = max(0.0, 1.0 - abs(d.y) / len) * exp(-abs(d.x) * 60.0);

    // Faint diagonal spikes for a more "sparkly" look
    vec2 dd = vec2(d.x + d.y, d.x - d.y) * 0.7071;
    float dlen = len * 0.6;
    float spike_d1 = max(0.0, 1.0 - abs(dd.x) / dlen) * exp(-abs(dd.y) * 80.0);
    float spike_d2 = max(0.0, 1.0 - abs(dd.y) / dlen) * exp(-abs(dd.x) * 80.0);

    float spikes = (spike_h + spike_v + 0.45 * (spike_d1 + spike_d2))
        * pulse * is_special * glimmer_strength * (1.0 + is_super * 1.5);

    // Base star color from the wide palette
    float color_seed = hash21(cell + 101.9);
    vec3 star_color = star_palette(color_seed);

    // Special stars continuously cycle through the full hue wheel
    float hue = TIME * color_cycle_speed * mix(0.5, 1.7, hash21(cell + 345.2))
        + hash21(cell + 357.8);
    vec3 cycle_color = 0.5 + 0.5 * cos(TAU * (hue + vec3(0.0, 0.33, 0.67)));
    cycle_color = mix(vec3(1.0), cycle_color, color_saturation);
    star_color = mix(star_color, cycle_color, is_special * 0.95);

    float intensity = mix(0.5, 2.2, pow(hash21(cell + 211.4), 1.5));
    intensity *= 1.0 + is_special * 0.6 + is_super * 0.6;
    float twinkle_speed = mix(0.6, 1.8, hash21(cell + 131.7));
    float twinkle_phase = hash21(cell + 157.3) * TAU;
    float twinkle_amount = mix(0.05, 0.20, hash21(cell + 181.1));
    float twinkle = 1.0 - twinkle_amount * 0.5
        + twinkle_amount * 0.5 * sin(TIME * twinkle_speed + twinkle_phase);

    float star_light = (star_mask + spikes) * intensity * twinkle * star_brightness;

    COLOR = background_color + star_color * star_light;
}
