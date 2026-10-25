#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    float cornerRadius;
    vec2 rippleOrigin;
    float rippleProgress;
    float rippleOpacity;
    float stateOpacity;
    vec4 rippleColor;
} ubuf;

void main()
{
    vec2 point = qt_TexCoord0 * ubuf.size;
    float radius = clamp(ubuf.cornerRadius, 0.0, min(ubuf.size.x, ubuf.size.y) * 0.5);
    vec2 edge = abs(point - ubuf.size * 0.5) - ubuf.size * 0.5 + radius;
    float distanceToEdge = length(max(edge, vec2(0.0)))
        + min(max(edge.x, edge.y), 0.0) - radius;
    float edgeAA = max(fwidth(distanceToEdge), 0.0001);
    float mask = 1.0 - smoothstep(-edgeAA * 0.5, edgeAA * 0.5, distanceToEdge);

    vec2 origin = clamp(ubuf.rippleOrigin, vec2(0.0), ubuf.size);
    float coverage = length(max(origin, ubuf.size - origin));
    float distanceToRipple = length(point - origin)
        - coverage * clamp(ubuf.rippleProgress, 0.0, 1.0);
    float rippleAA = max(fwidth(distanceToRipple), 0.0001);
    float wave = (1.0 - smoothstep(-rippleAA * 0.5, rippleAA * 0.5, distanceToRipple))
        * step(0.0001, ubuf.rippleProgress);
    float pulse = clamp(ubuf.rippleOpacity, 0.0, 1.0);
    // One resolved alpha, matching painter source-over without stacking state layers.
    float alpha = clamp(ubuf.stateOpacity, 0.0, 1.0) * (1.0 - pulse) + wave * pulse;
    fragColor = ubuf.rippleColor * alpha * mask * ubuf.qt_Opacity;
}
