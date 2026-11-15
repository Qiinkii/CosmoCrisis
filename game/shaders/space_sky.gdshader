shader_type sky;

uniform vec3 space_color : source_color = vec3(0.001, 0.002, 0.006);
uniform vec3 nebula_color : source_color = vec3(0.006, 0.010, 0.026);
uniform float star_brightness : hint_range(1.0, 8.0) = 4.0;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void sky() {
    vec3 direction = normalize(SKY_COORDS);
    vec2 uv = vec2(
        atan(direction.z, direction.x) / TAU + 0.5,
        asin(clamp(direction.y, -1.0, 1.0)) / PI + 0.5
    );

    float haze = smoothstep(-0.45, 0.8, sin(uv.x * 8.0 + sin(uv.y * 5.0)) * cos(uv.y * 7.0));
    vec3 background_color = mix(space_color, nebula_color, haze * 0.25);

    // Randomized stars: every sky cell has a stable random position, color,
    // size, brightness, and twinkle phase. 300 x 150 cells at 40% occupancy
    // produces about 18,000 stars over the full sky sphere.
    vec2 grid = uv * vec2(300.0, 150.0);
    vec2 cell = floor(grid);
    vec2 cell_uv = fract(grid);
    float star_chance = hash21(cell);
    vec2 star_uv = vec2(hash21(cell + 17.17), hash21(cell + 43.71));
    float size_seed = hash21(cell + 79.31);
    float star_radius = mix(0.018, 0.055, size_seed);
    float star_distance = length((cell_uv - star_uv) * vec2(1.0, 0.5));
    float star_core = 1.0 - smoothstep(star_radius * 0.25, star_radius, star_distance);
    float star_halo = 1.0 - smoothstep(star_radius, star_radius + 0.055, star_distance);
    float star_mask = step(0.60, star_chance) * (star_core + star_halo * 0.18);

    float color_seed = hash21(cell + 101.9);
    vec3 star_color = mix(
        vec3(1.0, 0.76, 0.58),
        vec3(0.72, 0.86, 1.0),
        color_seed
    );
    float intensity = mix(0.5, 2.2, pow(hash21(cell + 211.4), 1.5));
    float twinkle_speed = mix(0.6, 1.8, hash21(cell + 131.7));
    float twinkle_phase = hash21(cell + 157.3) * TAU;
    float twinkle_amount = mix(0.05, 0.20, hash21(cell + 181.1));
    float twinkle = 1.0 - twinkle_amount * 0.5
        + twinkle_amount * 0.5 * sin(TIME * twinkle_speed + twinkle_phase);
    float star_light = star_mask * intensity * twinkle * star_brightness;

    COLOR = background_color + star_color * star_light;
}
