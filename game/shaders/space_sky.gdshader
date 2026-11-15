shader_type sky;

uniform vec3 space_color : source_color = vec3(0.0015, 0.0025, 0.008);
uniform vec3 nebula_color : source_color = vec3(0.008, 0.012, 0.032);

float hash21(vec2 point) {
    vec2 p = fract(point * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec3 star_layer(vec2 uv, vec2 grid_scale, float density, float min_radius, float max_radius, float brightness_scale, float time) {
    vec2 grid = uv * grid_scale;
    vec2 cell = floor(grid);
    vec2 local_pos = fract(grid) - vec2(0.5);
    float seed = hash21(cell);
    vec2 jitter = (vec2(hash21(cell + 13.1), hash21(cell + 71.7)) - vec2(0.5)) * 0.72;

    float size_seed = hash21(cell + 31.4);
    float radius = mix(min_radius, max_radius, size_seed);
    float star = 1.0 - smoothstep(radius, radius + 0.035, length(local_pos - jitter));
    star *= step(1.0 - density, seed);

    float color_seed = hash21(cell + 52.8);
    vec3 warm = vec3(1.0, 0.78, 0.62);
    vec3 white = vec3(0.88, 0.94, 1.0);
    vec3 blue = vec3(0.62, 0.78, 1.0);
    vec3 tint = mix(mix(warm, white, smoothstep(0.0, 0.55, color_seed)), blue, smoothstep(0.55, 1.0, color_seed));

    float intensity = mix(0.65, 2.0, pow(hash21(cell + 91.8), 1.7));
    float speed = mix(0.65, 1.7, hash21(cell + 17.6));
    float twinkle_amount = mix(0.06, 0.22, hash21(cell + 39.2));
    float phase = hash21(cell + 73.5) * TAU;
    float twinkle = 1.0 - twinkle_amount * 0.5 + twinkle_amount * 0.5 * sin(time * speed + phase);

    return tint * star * intensity * twinkle * brightness_scale;
}

void sky() {
    vec3 direction = normalize(SKY_COORDS);
    vec2 uv = vec2(
        atan(direction.z, direction.x) / TAU + 0.5,
        asin(clamp(direction.y, -1.0, 1.0)) / PI + 0.5
    );

    float haze = smoothstep(-0.45, 0.8, sin(uv.x * 8.0 + sin(uv.y * 5.0)) * cos(uv.y * 7.0));
    vec3 background = mix(space_color, nebula_color, haze * 0.34);

    // About 10,000 primary stars over the full sky sphere (300 x 150 cells at 22% density).
    vec3 dense_stars = star_layer(uv, vec2(300.0, 150.0), 0.22, 0.055, 0.14, 1.0, TIME);
    // A sparse layer of larger, brighter stars adds depth and more noticeable glimmers.
    vec3 bright_stars = star_layer(uv, vec2(150.0, 75.0), 0.045, 0.08, 0.18, 1.8, TIME * 0.75);

    COLOR = background + dense_stars + bright_stars;
}
