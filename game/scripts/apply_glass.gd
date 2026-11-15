extends Node3D
## Attach to the root node "lastship" in res://shatl/lastship.tscn.

const SHADER_PATH := "res://shaders/porthole_glass.gdshader"

## Tick this in the inspector to make the glass clearly visible (for testing).
@export var debug_visible: bool = false
@export_range(0.0, 1.0) var base_opacity: float = 0.06
@export_range(0.0, 1.0) var reflection_strength: float = 0.3
@export_range(0.0, 1.0) var glare_strength: float = 0.12

func _ready() -> void:
	if not ResourceLoader.exists(SHADER_PATH):
		push_error("apply_glass: shader not found at " + SHADER_PATH)
		return
	var shader := load(SHADER_PATH) as Shader
	if shader == null:
		push_error("apply_glass: could not load shader (check it for compile errors)")
		return

	var mat := ShaderMaterial.new()
	mat.shader = shader
	if debug_visible:
		mat.set_shader_parameter("glass_tint", Color(0.3, 0.8, 1.0, 0.5))
		mat.set_shader_parameter("reflection_strength", 1.0)
		mat.set_shader_parameter("glare_strength", 0.6)
	else:
		mat.set_shader_parameter("glass_tint", Color(0.55, 0.70, 0.85, base_opacity))
		mat.set_shader_parameter("reflection_strength", reflection_strength)
		mat.set_shader_parameter("glare_strength", glare_strength)

	var count := 0
	for node in find_children("*", "MeshInstance3D", true, false):
		if String(node.name).to_lower().contains("glass"):
			(node as MeshInstance3D).material_override = mat
			count += 1
	print("apply_glass: applied to %d glass meshes" % count)
