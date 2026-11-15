extends CanvasLayer

@export var telemetry_path: NodePath
@export var player_path: NodePath

@onready var effect_rect: ColorRect = $EffectRect

var telemetry: Node = null
var player: Node = null
var shader_mat: ShaderMaterial = null

var base_move_speed: float = 5.0
var base_mouse_sensitivity: float = 0.002

func _ready() -> void:
	layer = 10
	effect_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	effect_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	shader_mat = effect_rect.material as ShaderMaterial
	if shader_mat == null:
		shader_mat = ShaderMaterial.new()
		shader_mat.shader = load("res://Shaders/hypercapnia.gdshader")
		effect_rect.material = shader_mat

	telemetry = get_node_or_null(telemetry_path)
	if telemetry == null and get_tree().current_scene != null:
		telemetry = get_tree().current_scene.find_child("ShipTelemetry", true, false)
	if telemetry == null:
		telemetry = _find_node_with_property(get_tree().root, "co2_level")

	player = get_node_or_null(player_path)
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player == null and get_tree().current_scene != null:
		player = get_tree().current_scene.find_child("Player", true, false)

	if player != null and "move_speed" in player:
		base_move_speed = player.move_speed
	if player != null and "mouse_sensitivity" in player:
		base_mouse_sensitivity = player.mouse_sensitivity

	effect_rect.visible = false
	shader_mat.set_shader_parameter("blur_strength", 0.0)
	shader_mat.set_shader_parameter("vignette_strength", 0.0)

	if telemetry != null and telemetry.has_signal("mission_failed"):
		if not telemetry.is_connected("mission_failed", _on_mission_failed):
			telemetry.connect("mission_failed", _on_mission_failed)

func _find_node_with_property(root: Node, prop_name: String) -> Node:
	if root == null:
		return null
	if prop_name in root:
		return root
	for child in root.get_children():
		var found := _find_node_with_property(child, prop_name)
		if found != null:
			return found
	return null

func _process(_delta: float) -> void:
	if telemetry == null or not ("co2_level" in telemetry):
		return

	var co2: float = float(telemetry.get("co2_level"))
	var severity: float = clampf((co2 - 0.5) / 1.5, 0.0, 1.0)

	effect_rect.visible = severity > 0.01
	if shader_mat != null:
		shader_mat.set_shader_parameter("blur_strength", severity * 3.5)
		shader_mat.set_shader_parameter("vignette_strength", severity * 0.9)

	if player != null:
		if "move_speed" in player:
			player.set("move_speed", lerpf(base_move_speed, base_move_speed * 0.45, severity))
		if "mouse_sensitivity" in player:
			player.set("mouse_sensitivity", lerpf(base_mouse_sensitivity, base_mouse_sensitivity * 0.5, severity))

func _on_mission_failed(reason: String) -> void:
	print("ПОРАЗКА: ", reason)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
