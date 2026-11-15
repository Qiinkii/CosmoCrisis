extends SubViewportContainer
## Slowly drifting procedural starfield for menus.
##
## Renders res://shaders/space_sky.gdshader (the same sky used in the ship)
## through a camera that turns very slowly, so the stars appear to flow as if
## the viewer were rotating in free space. The star layout is randomised on
## every launch via the shader's `seed_offset` uniform.

## Horizontal turn speed in degrees per second.
@export var yaw_speed_deg: float = 1.6
## How far the view bobs up/down, in degrees (kept small to avoid pole distortion).
@export var pitch_amplitude_deg: float = 5.0
@export var pitch_period: float = 70.0
## Slight roll for a floating feel, in degrees.
@export var roll_amplitude_deg: float = 1.5
@export var roll_period: float = 110.0

@onready var camera: Camera3D = %Camera
@onready var world_environment: WorldEnvironment = %WorldEnvironment

var _yaw_deg: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	var sky: Sky = world_environment.environment.sky
	var material := sky.sky_material as ShaderMaterial
	if material != null:
		material.set_shader_parameter(
			"seed_offset",
			Vector2(randf_range(0.0, 64.0), randf_range(0.0, 64.0))
		)

	_yaw_deg = randf() * 360.0
	_time = randf() * 1000.0
	_apply_camera()

func _process(delta: float) -> void:
	_time += delta
	_yaw_deg = fposmod(_yaw_deg - yaw_speed_deg * delta, 360.0)
	_apply_camera()

func _apply_camera() -> void:
	camera.rotation_degrees = Vector3(
		sin(_time * TAU / pitch_period) * pitch_amplitude_deg,
		_yaw_deg,
		sin(_time * TAU / roll_period) * roll_amplitude_deg
	)
