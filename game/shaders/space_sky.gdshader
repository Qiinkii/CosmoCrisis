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

    vec2 grid = uv * vec2(420.0, 210.0);
    vec2 cell = floor(grid);
    vec2 local_pos = fract(grid) - 0.5;
    float seed = hash21(cell);
    vec2 jitter = (vec2(hash21(cell + 13.1), hash21(cell + 71.7)) - 0.5) * 0.72;
    float radius = mix(0.012, 0.032, hash21(cell + 31.4));
    float star = 1.0 - smoothstep(radius, radius + 0.012, length(local_pos - jitter));
    star *= step(0.992, seed);

    float twinkle = 0.78 + 0.22 * sin(TIME * (1.2 + seed * 2.0) + seed * TAU);
    float brightness = star * twinkle * mix(0.55, 1.0, hash21(cell + 91.8));

    COLOR = sky_color + vec3(0.72, 0.84, 1.0) * brightness;
}
