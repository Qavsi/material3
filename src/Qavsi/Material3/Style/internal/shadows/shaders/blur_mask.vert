// Adapted from QmlMaterial 229bc3e6 (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived Gaussian model (BSD-3-Clause); see third_party/shadow-reference.
#version 440

#ifdef QSHADER_GLSL_ES
#define noperspective
#endif

layout(location = 0) in vec2 in_position;
layout(location = 1) in vec4 in_color;

layout(location = 0) noperspective out vec2 v_pos;
layout(location = 1) noperspective out vec4 v_color;

layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    float sigma;
    vec2  rect_size;
    int   style;
    float radius;
    float radius_tl;
    float radius_tr;
    float radius_bl;
    float radius_br;
    vec4 corner_uv[4];
};

void main() {
    v_pos       = in_position;
    v_color     = in_color;
    gl_Position = qt_Matrix * vec4(in_position, 0.0, 1.0);
}
