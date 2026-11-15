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

	# Reset screen effects at startup.
	effect_rect.visible = false
	var mat := effect_rect.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("blur_strength", 0.0)
		mat.set_shader_parameter("vignette_strength", 0.0)
		mat.set_shader_parameter("heat_haze_strength", 0.0)

	if telemetry != null and not telemetry.mission_failed.is_connected(_on_mission_failed):
		telemetry.mission_failed.connect(_on_mission_failed)

func _process(_delta: float) -> void:
	if telemetry == null:
		return

	# CO2 effects start at 0.5% and reach maximum at 2.0%.
	var severity: float = clampf((telemetry.co2_level - 0.5) / 1.5, 0.0, 1.0)
	# Heat haze starts above 40°C and intensifies up to the 50°C failure threshold.
	var heat_severity: float = clampf((telemetry.air_temperature - 40.0) / 10.0, 0.0, 1.0)

	effect_rect.visible = severity > 0.01 or heat_severity > 0.01
	var mat := effect_rect.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("blur_strength", severity * 3.0)
		mat.set_shader_parameter("vignette_strength", severity * 0.85)
		mat.set_shader_parameter("heat_haze_strength", heat_severity)

	if player != null:
		player.move_speed = lerpf(base_move_speed, base_move_speed * 0.45, severity)
		player.mouse_sensitivity = lerpf(base_mouse_sensitivity, base_mouse_sensitivity * 0.5, severity)

func _on_mission_failed(reason: String) -> void:
	print("ПОРАЗКА: ", reason)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
