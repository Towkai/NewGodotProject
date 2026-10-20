shader_type spatial;
render_mode ambient_light_disabled;

group_uniforms Color;
uniform sampler2D base_tex : source_color, filter_linear_mipmap;
uniform float saturation : hint_range(0.0, 3.0, 0.01) = 1.0;
group_uniforms;

group_uniforms Shadow;
uniform float shadow_threshold : hint_range(0.0, 1.0, 0.001) = 0.05;
uniform float shadow_smoothness : hint_range(0.001, 0.5, 0.001) = 0.01;
uniform float shadow_color_mix : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec3 shadow_color : source_color = vec3(0.0);
group_uniforms;

const vec3 GRAY = vec3(0.299, 0.587, 0.114);

void fragment() {
    vec3 base_color = texture(base_tex, UV).rgb;

    float luminance = dot(base_color, GRAY);
    base_color = mix(
        vec3(luminance),
        base_color,
        saturation
    );

    ALBEDO = base_color;
}

void light() {
    float ndotl = max(dot(NORMAL, LIGHT), 0.0);

    // Toon 明暗交界
    float toon = smoothstep(
        shadow_threshold - shadow_smoothness,
        shadow_threshold + shadow_smoothness,
        ndotl
    );

    // 接收實際陰影
    toon *= ATTENUATION;

    // 陰影材質顏色
    vec3 shadow_albedo = mix(
        ALBEDO,
        shadow_color,
        shadow_color_mix
    );

    // 平面化的二階光照
    vec3 final_albedo = mix(
        shadow_albedo,
        ALBEDO,
        toon
    );

    DIFFUSE_LIGHT += final_albedo * LIGHT_COLOR / PI;
}