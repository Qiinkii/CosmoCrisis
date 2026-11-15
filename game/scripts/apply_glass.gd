extends Node3D
## Attach to the root node "lastship" in res://shatl/lastship.tscn.
## Replaces the material on every glass mesh with the porthole glass shader.

@export var glass_shader: Shader = preload("res://shaders/porthole_glass.gdshader")

func _ready() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = glass_shader
	for node in find_children("*", "MeshInstance3D", true, false):
		var n := String(node.name).to_lower()
		# Matches the 8 glass nodes in lastship.tscn:
		# Cockpit_roof/side_1/side_-1 and Nose_convex "..._transparent_glass_002",
		# Engineering_upper_window_1/-1 "..._transparent_glass_002",
		# Observation_Port_Glass and Observation_Starboard_Glass
		if n.contains("glass"):
			(node as MeshInstance3D).material_override = mat
