shader_type sky;

uniform vec3 space_color : source_color = vec3(0.004, 0.008, 0.025);
uniform vec3 nebula_color : source_color = vec3(0.018, 0.025, 0.075);

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
    vec3 sky_color = mix(space_color, nebula_color, haze * 0.38);

    // Each grid cell gets stable random properties, so star placement and
    // appearance vary across the sky without changing from frame to frame.
    vec2 grid = uv * vec2(420.0, 210.0);
    vec2 cell = floor(grid);
    vec2 local_pos = fract(grid) - 0.5;
    float seed = hash21(cell);
    vec2 jitter = (vec2(hash21(cell + 13.1), hash21(cell + 71.7)) - 0.5) * 0.72;

    // Mostly faint pinpoints, with a few brighter and slightly larger stars.
    float size_seed = hash21(cell + 31.4);
    float radius = mix(0.010, 0.030, size_seed);
    float star = 1.0 - smoothstep(radius, radius + 0.012, length(local_pos - jitter));
    star *= step(0.991, seed);

    // Vary color from warm white through neutral to cool blue-white.
    float color_seed = hash21(cell + 52.8);
    vec3 warm_star = vec3(1.0, 0.77, 0.56);
    vec3 cool_star = vec3(0.60, 0.78, 1.0);
    vec3 star_color = mix(warm_star, cool_star, color_seed);

    // Per-star brightness and gentle, independently phased glimmer.
    float intensity = mix(0.35, 1.35, pow(hash21(cell + 91.8), 2.2));
    float twinkle_speed = mix(0.65, 1.8, hash21(cell + 17.6));
    float twinkle_amount = mix(0.06, 0.24, hash21(cell + 39.2));
    float twinkle_phase = hash21(cell + 73.5) * TAU;
    float twinkle = 1.0 - twinkle_amount * 0.5
        + twinkle_amount * 0.5 * sin(TIME * twinkle_speed + twinkle_phase);
    float brightness = star * intensity * twinkle;

    COLOR = sky_color + star_color * brightness;
}
