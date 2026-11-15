shader_type sky;

uniform vec3 space_color : source_color = vec3(0.001, 0.002, 0.006);
uniform vec3 nebula_color : source_color = vec3(0.006, 0.010, 0.026);
uniform float star_brightness : hint_range(0.5, 5.0) = 2.8;
uniform float star_density : hint_range(0.05, 0.6) = 0.28;

float hash21(vec2 point) {
    vec2 p = fract(point * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec3 star_field(vec2 uv, vec2 grid_size, float density, float scale, float time) {
    vec2 grid = uv * grid_size;
    vec2 cell = floor(grid);
    vec2 point_in_cell = fract(grid);

    // Each cell gets one stable pseudo-random star position and appearance.
    float seed = hash21(cell);
    vec2 star_position = vec2(hash21(cell + 17.17), hash21(cell + 43.71));
    float size_seed = hash21(cell + 79.31);
    float visible = step(1.0 - density, seed);
    float radius = mix(0.018, 0.060, size_seed) * scale;
    float distance_to_star = length((point_in_cell - star_position) * vec2(1.0, 0.5));

    // A soft halo makes stars readable through the cockpit glass, with a bright core.
    float halo = (1.0 - smoothstep(radius, radius + 0.10, distance_to_star)) * 0.24;
    float core = 1.0 - smoothstep(radius * 0.22, radius * 0.55, distance_to_star);

    float color_seed = hash21(cell + 101.9);
    vec3 warm_white = vec3(1.0, 0.78, 0.62);
    vec3 neutral_white = vec3(0.90, 0.96, 1.0);
    vec3 blue_white = vec3(0.62, 0.78, 1.0);
    vec3 color = mix(mix(warm_white, neutral_white, smoothstep(0.0, 0.55, color_seed)), blue_white, smoothstep(0.55, 1.0, color_seed));

    float speed = mix(0.6, 1.8, hash21(cell + 131.7));
    float phase = hash21(cell + 157.3) * TAU;
    float amount = mix(0.05, 0.22, hash21(cell + 181.1));
    float twinkle = 1.0 - amount * 0.5 + amount * 0.5 * sin(time * speed + phase);
    float intensity = mix(0.7, 2.8, pow(hash21(cell + 211.4), 1.7));

    return color * visible * (halo + core * intensity) * twinkle;
}

void sky() {
    vec3 direction = normalize(SKY_COORDS);
    vec2 uv = vec2(
        atan(direction.z, direction.x) / TAU + 0.5,
        asin(clamp(direction.y, -1.0, 1.0)) / PI + 0.5
    );

    float haze = smoothstep(-0.45, 0.8, sin(uv.x * 8.0 + sin(uv.y * 5.0)) * cos(uv.y * 7.0));
    vec3 background = mix(space_color, nebula_color, haze * 0.30);

    // 300 x 150 cells at 28% occupancy yields roughly 12,600 randomly placed stars.
    vec3 stars = star_field(uv, vec2(300.0, 150.0), star_density, 1.0, TIME);
    // Small additional stars fill gaps and make the sky feel richly populated.
    stars += star_field(uv, vec2(520.0, 260.0), 0.12, 0.52, TIME * 0.8) * 0.55;

    COLOR = background + stars * star_brightness;
}
