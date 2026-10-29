
@tool
extends EditorScript

const TOON: Shader = preload(
    "res://bilibili/BV1x9wezwER6/Shaders/toon.gdshader"
)

# true = 只替換名稱包含指定關鍵字的 Mesh
const FILTER_BY_NAME := false
const NAME_KEYWORD := "hair"


func _run() -> void:
    var root := EditorInterface.get_edited_scene_root()

    if root == null:
        push_error("沒有開啟場景")
        return

    var replaced := 0

    for node in get_all_children(root):
        if not node is MeshInstance3D:
            continue

        var mesh_node := node as MeshInstance3D

        if mesh_node.mesh == null:
            continue

        if FILTER_BY_NAME:
            if not NAME_KEYWORD.to_lower() in mesh_node.name.to_lower():
                continue

        var surface_count := mesh_node.mesh.get_surface_count()

        for i in range(surface_count):
            # 取得目前實際使用的材質
            var material := mesh_node.get_active_material(i)

            if not material is StandardMaterial3D:
                continue

            var old_material := material as StandardMaterial3D

            # 建立新的 ShaderMaterial
            var new_material := ShaderMaterial.new()
            new_material.shader = TOON

            # 保留原本的貼圖
            new_material.set_shader_parameter(
                "base_tex",
                old_material.albedo_texture
            )

            # 假設 Shader 有 base_color 參數
            new_material.set_shader_parameter(
                "base_color",
                old_material.albedo_color
            )

            # 只覆寫 MeshInstance3D 的材質
            mesh_node.set_surface_override_material(
                i,
                new_material
            )

            replaced += 1

    print("完成！替換了 %d 個材質 Surface" % replaced)


func get_all_children(root: Node) -> Array[Node]:
    var result: Array[Node] = [root]

    for child in root.get_children():
        result.append_array(get_all_children(child))

    return result
