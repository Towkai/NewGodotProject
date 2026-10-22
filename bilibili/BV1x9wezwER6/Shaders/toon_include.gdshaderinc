render_mode ambient_light_disabled;
uniform sampler2D base_tex;

group_uniforms color;
uniform vec3 base_color: source_color = vec3(1.0);
uniform float saturaion: hint_range(.0, 3.0) = 1.0;
const vec3 Gray = vec3(.299, .587, .114);
group_uniforms;

group_uniforms shadow;
uniform float shadow_offset: hint_range(.0, 1.0) = .5;
uniform float shadow_color_mix: hint_range(.0, 1.0) = .5;
uniform vec3 shadow_color: source_color = vec3(.0);
group_uniforms; // 結束 group 區籤

float lambert_shadow(vec3 normal, vec3 light, float attenuation) {
	return clamp(dot(normal, light) * attenuation, .0, 1.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 color = texture(base_tex, UV).rgb * base_color;
	vec3 gray = vec3(dot(color, Gray));
	color = mix(gray, color, saturaion);
	ALBEDO = color;
}

void light() {
    
#ifdef USE_FACE_SDF
    float shadow;
#else
    float shadow = lambert_shadow(NORMAL, LIGHT, ATTENUATION);
#endif

    // 1. 計算出條件權重：當 shadow > 0.5 時為 1.0，否則為 0.0
    float is_bright = step(shadow_offset, shadow);

    // 2. 預先計算出兩邊共同需要的公式項
    vec3 lit_color = shadow * ALBEDO;
    vec3 dark_color = mix(ALBEDO, shadow_color, shadow_color_mix);

    // 3. 使用 mix() 代替 if-else，完全消除分支
    vec3 final_color = mix(dark_color, lit_color, is_bright);

    DIFFUSE_LIGHT += final_color * LIGHT_COLOR / PI;
}

