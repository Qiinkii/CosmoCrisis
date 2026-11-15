shader_type sky;

uniform vec3 space_color : source_color = vec3(0.002, 0.004, 0.012);
uniform vec3 nebula_color : source_color = vec3(0.012, 0.018, 0.045);

float hash21(vec2 point) {
    vec2 p = fract(point * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec3 make_star_layer(vec2 uv, vec2 grid_scale, float density, float size_scale, float time) {
    vec2 grid = uv * grid_scale;
    vec2 cell = floor(grid);
    vec2 local_pos = fract(grid) - vec2(0.5);
    float seed = hash21(cell);
    vec2 jitter = (vec2(hash21(cell + 13.1), hash21(cell + 71.7)) - vec2(0.5)) * 0.62;

    float size_seed = hash21(cell + 31.4);
    float radius = mix(0.018, 0.060, size_seed) * size_scale;
    float star_mask = 1.0 - smoothstep(radius, radius + 0.018, length(local_pos - jitter));
    star_mask *= step(1.0 - density, seed);

    float color_seed = hash21(cell + 52.8);
    vec3 warm_star = vec3(1.0, 0.78, 0.62);
    vec3 neutral_star = vec3(0.88, 0.94, 1.0);
    vec3 cool_star = vec3(0.60, 0.78, 1.0);
    vec3 star_color = mix(
        mix(warm_star, neutral_star, smoothstep(0.0, 0.55, color_seed)),
        cool_star,
        smoothstep(0.55, 1.0, color_seed)
    );

    float intensity = mix(0.65, 2.4, pow(hash21(cell + 91.8), 2.0));
    float twinkle_speed = mix(0.7, 1.8, hash21(cell + 17.6));
    float twinkle_amount = mix(0.08, 0.28, hash21(cell + 39.2));
    float twinkle_phase = hash21(cell + 73.5) * TAU;
    float twinkle = 1.0 - twinkle_amount * 0.5
        + twinkle_amount * 0.5 * sin(time * twinkle_speed + twinkle_phase);
    float brightness = star_mask * intensity * twinkle * mix(0.55, 1.0, size_seed);

    return star_color * brightness;
}

void sky() {
    vec3 direction = normalize(SKY_COORDS);
    vec2 uv = vec2(
        atan(direction.z, direction.x) / TAU + 0.5,
        asin(clamp(direction.y, -1.0, 1.0)) / PI + 0.5
    );

    float haze = smoothstep(-0.45, 0.8, sin(uv.x * 8.0 + sin(uv.y * 5.0)) * cos(uv.y * 7.0));
    vec3 sky_color = mix(space_color, nebula_color, haze * 0.38);

    vec3 primary_stars = make_star_layer(uv, vec2(250.0, 125.0), 0.055, 1.0, TIME);
    vec3 fine_stars = make_star_layer(uv, vec2(520.0, 260.0), 0.018, 0.45, TIME * 0.8);

    COLOR = sky_color + primary_stars + fine_stars * 0.45;
}
