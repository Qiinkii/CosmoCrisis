extends CanvasLayer

@export var telemetry_path: NodePath
@export var player_path: NodePath

@onready var effect_rect: ColorRect = $EffectRect

var telemetry: ShipTelemetry = null
var player: PlayerController = null

var base_move_speed: float = 5.0
var base_mouse_sensitivity: float = 0.002

func _ready() -> void:
	telemetry = get_node_or_null(telemetry_path) as ShipTelemetry
	if telemetry == null:
		telemetry = get_tree().current_scene.get_node_or_null("ShipTelemetry") as ShipTelemetry

	player = get_node_or_null(player_path) as PlayerController
	if player == null:
		player = get_tree().get_first_node_in_group("player") as PlayerController

	if player != null:
		base_move_speed = player.move_speed
		base_mouse_sensitivity = player.mouse_sensitivity

	# Сбрасываем визуал на старте (на случай если крутил ползунки шейдера в редакторе)
	effect_rect.visible = false
	var mat := effect_rect.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("blur_strength", 0.0)
		mat.set_shader_parameter("vignette_strength", 0.0)

	if telemetry != null and not telemetry.mission_failed.is_connected(_on_mission_failed):
		telemetry.mission_failed.connect(_on_mission_failed)
func _on_mission_failed(reason: String) -> void:
		print("ПОРАЗКА: ", reason)
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
