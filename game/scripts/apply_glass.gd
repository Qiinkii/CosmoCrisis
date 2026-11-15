extends Node

const SHADER_PATH := "res://shaders/porthole_glass.gdshader"

## Set to true to make the glass obviously visible while testing.
const DEBUG_VISIBLE := false

var _mat: ShaderMaterial

func _ready() -> void:
	print("GlassApplier: started")
	if not ResourceLoader.exists(SHADER_PATH):
		push_error("GlassApplier: shader not found at " + SHADER_PATH)
		return
	var shader := load(SHADER_PATH) as Shader
	if shader == null:
		push_error("GlassApplier: shader failed to load (check it for compile errors)")
		return

	_mat = ShaderMaterial.new()
	_mat.shader = shader
	if DEBUG_VISIBLE:
		_mat.set_shader_parameter("glass_tint", Color(0.3, 0.8, 1.0, 0.5))
		_mat.set_shader_parameter("reflection_strength", 1.0)
		_mat.set_shader_parameter("glare_strength", 0.6)

	# Apply to glass that already exists, and to any that gets added later.
	get_tree().node_added.connect(_on_node_added)
	var count := 0
	for node in get_tree().root.find_children("*", "MeshInstance3D", true, false):
		if _try_apply(node):
			count += 1
	print("GlassApplier: applied to %d glass meshes" % count)

func _on_node_added(node: Node) -> void:
	if _try_apply(node):
		print("GlassApplier: applied to ", node.name)

func _try_apply(node: Node) -> bool:
	if node is MeshInstance3D and String(node.name).to_lower().contains("glass"):
		(node as MeshInstance3D).material_override = _mat
		return true
	return false
