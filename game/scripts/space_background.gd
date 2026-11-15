extends SubViewportContainer
## Menu background: procedural starfield (res://shaders/space_sky.gdshader)
## plus a black-hole model, seen by a camera that slowly orbits around it.
##
## The sky is infinitely far away, so as the camera circles the hole and keeps
## looking at it, the stars drift past exactly like a real change of heading.
## The black hole itself turns with the camera (see `view_follow`) so the
## accretion disk and lensing arcs keep facing the viewer.
## The star layout is randomised on every launch via the shader's
## `seed_offset` uniform.

## Distance from the camera to the black hole, in world units.
@export var orbit_distance: float = 40.0
## Orbit speed in degrees per second (1.5 = one full lap in 4 minutes).
@export var orbit_speed_deg: float = 1.5
## 0 = keep circling all the way around. Above 0 = swing back and forth by
## +/- this many degrees around `front_azimuth_deg` instead of a full lap.
@export_range(0.0, 180.0, 1.0) var sweep_half_angle_deg: float = 0.0
@export var front_azimuth_deg: float = 0.0
## How much the black hole turns with the camera's view angle.
## 1 = its front always faces the camera, 0 = it stays fixed and the camera
## really circles around it (the far side of the lensing arcs becomes visible).
@export_range(0.0, 1.0, 0.05) var view_follow: float = 1.0
## Average camera height above the disk plane, plus a slow up/down sway.
@export var elevation_deg: float = 14.0
@export var elevation_sway_deg: float = 8.0
@export var elevation_period: float = 90.0
## Where the black hole sits on screen, as a fraction of the screen size from
## the centre (+0.25 on X = a quarter of the width to the right).
@export_range(-0.5, 0.5, 0.01) var hole_screen_x: float = 0.25
@export_range(-0.5, 0.5, 0.01) var hole_screen_y: float = 0.0

@onready var camera: Camera3D = %Camera
@onready var black_hole: Node3D = %BlackHole
@onready var black_hole_pivot: Node3D = %BlackHolePivot
@onready var world_environment: WorldEnvironment = %WorldEnvironment

var _azimuth_deg: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	var sky: Sky = world_environment.environment.sky
	var sky_material := sky.sky_material as ShaderMaterial
	if sky_material != null:
		sky_material.set_shader_parameter(
			"seed_offset",
			Vector2(randf_range(0.0, 64.0), randf_range(0.0, 64.0))
		)

	_azimuth_deg = randf() * 360.0
	_time = randf() * 1000.0
	_apply_camera()

func _process(delta: float) -> void:
	_time += delta
	if sweep_half_angle_deg <= 0.0:
		_azimuth_deg = fposmod(_azimuth_deg + orbit_speed_deg * delta, 360.0)
	else:
		# sin() argument is in radians; this keeps the peak speed at orbit_speed_deg.
		_azimuth_deg = front_azimuth_deg + sweep_half_angle_deg * sin(
			_time * orbit_speed_deg / sweep_half_angle_deg
		)
	_apply_camera()

func _apply_camera() -> void:
	var elevation := deg_to_rad(
		elevation_deg + sin(_time * TAU / elevation_period) * elevation_sway_deg
	)
	var azimuth := deg_to_rad(_azimuth_deg)

	# Turn the black hole with the camera. The pivot rotates around world Y only,
	# so the model keeps the disk tilt it was authored with.
	black_hole_pivot.rotation.y = azimuth * view_follow

	var center := black_hole.global_position
	var direction := Vector3(
		sin(azimuth) * cos(elevation),
		sin(elevation),
		cos(azimuth) * cos(elevation)
	)
	camera.look_at_from_position(center + direction * orbit_distance, center, Vector3.UP)

	# Slide the camera sideways/up in its own frame so the hole appears off-centre
	# (parallel shift, so the orbit itself is unchanged). Sized from the visible
