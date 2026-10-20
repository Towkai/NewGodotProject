shader_type spatial;

uniform sampler2D hair_d : source_color;
uniform sampler2D hair_hn : repeat_enable;

uniform vec3 hair_color : source_color = vec3(0.18, 0.20, 0.22);

uniform bool use_ba = false;
uniform float normal_strength : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 base = texture(hair_d, UV);
    vec4 hn = texture(hair_hn, UV);

    ALBEDO = base.rgb * hair_color;
    METALLIC = 0.0;
    ROUGHNESS = 0.8;

    // 選擇候選法線 XY
    vec2 xy = use_ba ? hn.ba : hn.rg;

    // 將 0~1 解碼為 -1~1
    xy = xy * 2.0 - 1.0;

    // 調整法線細節強度
    xy *= normal_strength;

    // 重新計算 Z
    float z = sqrt(max(1.0 - dot(xy, xy), 0.0));

    vec3 normal = normalize(vec3(xy, z));

    // Godot NORMAL_MAP 使用 0~1 的編碼
    NORMAL_MAP = normal * 0.5 + 0.5;
}