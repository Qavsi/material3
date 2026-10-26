#version 440

// Adapted from QmlMaterial 229bc3e6 (MIT) and AOSP realistic ripple (Apache-2.0).
// Copyright (C) 2021 The Android Open Source Project.
// Driver constants: Copyright 2023 Google LLC (BSD). See third_party/ripple-reference.

// Analytic port of the pinned QmlMaterial/Skia ripple; no textures or Skia runtime.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    float cornerRadius;
    vec4 cornerRadii;
    vec2 rippleOrigin;
    float rippleProgress;
    float rippleOpacity;
    float stateOpacity;
    float ripplePhase;
    vec4 rippleColor;
    vec4 sparkleColor;
} ubuf;

const float PI = 3.14159265358979323846;

float subProgress(float start, float end, float progress)
{
    return clamp((progress - start) / (end - start), 0.0, 1.0);
}

float softCircle(vec2 point, vec2 center, float radius, float blur)
{
    if (!(radius > 0.0)) return 0.0;
    return 1.0 - smoothstep(1.0 - blur * 0.5, 1.0 + blur * 0.5,
                            length(point - center) / radius);
}

float softRing(vec2 point, vec2 center, float radius, float progress)
{
    float thickness = 0.05 * radius;
    float current = radius * progress;
    return clamp(softCircle(point, center, current + thickness, 1.0)
        - softCircle(point, center, max(current - thickness, 0.0), 1.0), 0.0, 1.0);
}

float triangleNoise(vec2 value)
{
    value = fract(value * vec2(5.3987, 5.4421));
    value += dot(value.yx, value.xy + vec2(21.5351, 14.3137));
    float xy = value.x * value.y;
    return fract(xy * 95.4307) + fract(xy * 75.04961) - 1.0;
}

float sparkles(vec2 uv, float phase)
{
    float noise = triangleNoise(uv);
    float value = 0.0;
    for (int i = 0; i < 4; ++i) {
        float low = float(i) * 0.1;
        float sampleValue = noise + sin(PI * (phase + 0.35 * float(i)));
        value += step(low, sampleValue) * (1.0 - step(low + 0.05, sampleValue));
    }
    return clamp(value, 0.0, 1.0);
}

float circleGrid(vec2 uv, vec2 center, float angle, float diameter)
{
    vec2 rotation = vec2(cos(angle), sin(angle));
    mat2 rotate = mat2(rotation.x, -rotation.y, rotation.y, rotation.x);
    vec2 coord = rotate * (center - uv) + center;
    coord = mod(coord, diameter) / vec2(0.8);
    float normalRadius = diameter / 0.8 * 0.5;
    float radius = normalRadius * 0.65;
    return softCircle(coord, vec2(normalRadius), radius, radius * 50.0);
}

float turbulence(vec2 uv, float phase)
{
    const float scale = 1.5;
    vec2 center1 = vec2(scale * 0.5)
        + phase * 0.01 * vec2(cos(scale * 0.55), sin(scale * 0.55));
    vec2 center2 = vec2(scale * 0.2)
        - phase * 0.0066 * vec2(cos(scale * 0.45), sin(scale * 0.45));
    vec2 center3 = vec2(scale)
        - phase * 0.0066 * vec2(cos(scale * 0.35), sin(scale * 0.35));
    float rotation = phase * PI * 0.0078125;
    float grid1 = circleGrid(uv * 0.8, center1, rotation + 1.7 * PI, 0.17);
    float grid2 = circleGrid(uv * 0.8, center2, -rotation + 2.0 * PI, 0.2);
    float grid3 = circleGrid(uv * 0.8, center3, rotation + 2.75 * PI, 0.275);
    return clamp(0.45 + 0.8 * (grid1 * grid1 + grid2 - grid3) * 0.5, 0.0, 1.0);
}

void main()
{
    if (!(ubuf.size.x > 0.0 && ubuf.size.y > 0.0 && ubuf.rippleColor.a > 0.0)) {
        fragColor = vec4(0.0);
        return;
    }
    vec2 point = qt_TexCoord0 * ubuf.size;
    float corner = point.y < ubuf.size.y * 0.5
        ? (point.x < ubuf.size.x * 0.5 ? ubuf.cornerRadii.x : ubuf.cornerRadii.y)
        : (point.x < ubuf.size.x * 0.5 ? ubuf.cornerRadii.z : ubuf.cornerRadii.w);
    float radius = clamp(corner >= 0.0 ? corner : ubuf.cornerRadius,
                         0.0, min(ubuf.size.x, ubuf.size.y) * 0.5);
    vec2 edge = abs(point - ubuf.size * 0.5) - ubuf.size * 0.5 + radius;
    float distanceToEdge = length(max(edge, vec2(0.0)))
        + min(max(edge.x, edge.y), 0.0) - radius;
    float edgeAA = max(fwidth(distanceToEdge), 0.0001);
    float mask = 1.0 - smoothstep(-edgeAA * 0.5, edgeAA * 0.5, distanceToEdge);

    float progress = clamp(ubuf.rippleProgress, 0.0, 1.0);
    vec4 ripple = vec4(0.0);
    if (progress > 0.0 && ubuf.rippleOpacity > 0.0) {
        vec2 touch = clamp(ubuf.rippleOrigin, vec2(0.0), ubuf.size);
        vec2 center = mix(touch, ubuf.size * 0.5, min(progress * 2.0, 1.0));
        float coverage = length(max(touch, ubuf.size - touch));
        float fadeIn = subProgress(0.0, 0.13, progress);
        float waveFade = min(fadeIn, 1.0 - subProgress(0.4, 1.0, progress));
        vec4 wave = ubuf.rippleColor
            * softCircle(point, center, coverage * progress, 1.0) * waveFade;
        float sparkleMix = 0.0;
        float noiseFade = min(fadeIn, 1.0 - subProgress(0.4, 0.5, progress));
        if (noiseFade > 0.0 && ubuf.sparkleColor.a > 0.0) {
            vec2 uv = point / ubuf.size;
            vec2 noiseScale = vec2(2.1) / ubuf.size;
            vec2 densityUv = uv - mod(uv, noiseScale);
            sparkleMix = sparkles(densityUv, ubuf.ripplePhase) * ubuf.sparkleColor.a
                * softRing(point, center, coverage, progress) * noiseFade
                * turbulence(uv, ubuf.ripplePhase);
        }
        // Qt color uniforms are already premultiplied. Preserve content alpha
        // for sparkles too; multiplying RGB by alpha again would darken them.
        vec4 sparkle = ubuf.sparkleColor * ubuf.rippleColor.a;
        ripple = mix(wave, sparkle, sparkleMix) * clamp(ubuf.rippleOpacity, 0.0, 1.0);
    }
    vec4 base = ubuf.rippleColor * clamp(ubuf.stateOpacity, 0.0, 1.0);
    fragColor = (ripple + base * (1.0 - ripple.a)) * mask * ubuf.qt_Opacity;
}
