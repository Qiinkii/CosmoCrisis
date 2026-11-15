extends CanvasLayer

@export var telemetry_path: NodePath
@export var player_path: NodePath

@onready var co2_effect: ColorRect = $CO2Effect
@onready var heat_effect: ColorRect = $HeatEffect

var telemetry: ShipTelemetry = null
var player: PlayerController = null

var base_move_speed: float = 5.0
var base_mouse_sensitivity: float = 0.002

func _ready() -> void:
	telemetry = get_node_or_null(telemetry_path) as ShipTelemetry
	if telemetry == null:
		telemetry = get_node_or_null("/root/ShipTelemetryGlobal") as ShipTelemetry
	if telemetry == null and get_tree().current_scene != null:
		telemetry = get_tree().current_scene.get_node_or_null("ShipTelemetry") as ShipTelemetry

	player = get_node_or_null(player_path) as PlayerController
	if player == null:
		player = get_tree().get_first_node_in_group("player") as PlayerController

	if player != null:
		base_move_speed = player.move_speed
		base_mouse_sensitivity = player.mouse_sensitivity

	# Keep CO2 sickness and heat haze as independent effects with separate materials.
	co2_effect.visible = false
	heat_effect.visible = false
	_set_shader_parameter(co2_effect, "blur_strength", 0.0)
	_set_shader_parameter(co2_effect, "vignette_strength", 0.0)
	_set_shader_parameter(heat_effect, "heat_haze_strength", 0.0)
	_set_shader_parameter(heat_effect, "blackout_strength", 0.0)

	if telemetry != null and not telemetry.mission_failed.is_connected(_on_mission_failed):
		telemetry.mission_failed.connect(_on_mission_failed)

func _process(_delta: float) -> void:
	if telemetry == null:
		return

	# CO2 symptoms start at 0.5% and intensify independently of temperature.
	var co2_severity: float = clampf((telemetry.co2_level - 0.5) / 1.5, 0.0, 1.0)
	# Red heat haze gradually intensifies from 40°C through 55°C.
	var heat_severity: float = clampf((telemetry.air_temperature - 40.0) / 15.0, 0.0, 1.0)
	# Vision progressively blacks out from 55°C to the revised 60°C failure threshold.
	var blackout_severity: float = clampf((telemetry.air_temperature - 55.0) / 5.0, 0.0, 1.0)

	co2_effect.visible = co2_severity > 0.01
	heat_effect.visible = heat_severity > 0.01 or blackout_severity > 0.01
	_set_shader_parameter(co2_effect, "blur_strength", co2_severity * 2.0)
	_set_shader_parameter(co2_effect, "vignette_strength", co2_severity * 0.75)
	_set_shader_parameter(heat_effect, "heat_haze_strength", heat_severity)
	_set_shader_parameter(heat_effect, "blackout_strength", blackout_severity)

	# Only CO2 sickness affects movement and focus; heat remains a visual effect.
	if player != null:
		player.move_speed = lerpf(base_move_speed, base_move_speed * 0.45, co2_severity)
		player.mouse_sensitivity = lerpf(base_mouse_sensitivity, base_mouse_sensitivity * 0.5, co2_severity)

func _set_shader_parameter(effect: ColorRect, parameter: StringName, value: float) -> void:
	var mat := effect.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter(parameter, value)

func _on_mission_failed(reason: String) -> void:
	print("ПОРАЗКА: ", reason)
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
