extends Node3D
## Self-contained radiator. No input handlers, player changes or autoloads.
signal deployment_changed(deployed: bool)
signal motion_started(deploying: bool)

@export_enum("L", "R") var side := "L"
@export var start_deployed := false
@export var camera_enabled := true
@export_range(1.0, 60.0) var camera_refresh_hz := 15.0
@export var camera_resolution := Vector2i(512, 384)

var deployed := false
var moving := false
var target_deployed := false
var _animation: AnimationPlayer
var _clips: Dictionary = {}
var _viewport: SubViewport
var _camera: Camera3D
var _mount: Node3D
var _elapsed := 0.0

func _ready() -> void:
	_animation = find_child("AnimationPlayer", true, false) as AnimationPlayer
	_mount = find_child("CameraMount", true, false) as Node3D
	if _animation == null:
		push_error("Radiator: AnimationPlayer is missing")
		return
	for clip in _animation.get_animation_list():
		if str(clip).ends_with("_Open"):
			_clips[true] = clip
		elif str(clip).ends_with("_Close"):
			_clips[false] = clip
	_animation.animation_finished.connect(_finished)
	set_deployed(start_deployed, true)
	if camera_enabled and _mount != null:
		_viewport = SubViewport.new()
		_viewport.name = "CameraFeed"
		_viewport.size = camera_resolution
		_viewport.world_3d = get_world_3d()
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		add_child(_viewport)
		_camera = Camera3D.new()
		_camera.fov = 90.0
		_camera.near = 0.025
		_viewport.add_child(_camera)
		_camera.global_transform = _mount.global_transform
		_camera.make_current()

func set_deployed(value: bool, instant := false) -> void:
	if _animation == null or not _clips.has(value):
		return
	if not instant and target_deployed == value:
		return
	var reverse_at := -1.0
	if moving and _animation.is_playing():
		reverse_at = _animation.current_animation_length - _animation.current_animation_position
	target_deployed = value
	_animation.play(_clips[value])
	if instant:
		_animation.advance(0.0)
		_animation.seek(_animation.current_animation_length, true)
		_animation.pause()
		deployed = value
		moving = false
	elif reverse_at >= 0.0:
		_animation.seek(reverse_at, true)
		moving = true
		motion_started.emit(value)
	else:
		moving = true
		motion_started.emit(value)

func toggle() -> void:
	set_deployed(not target_deployed)

func _finished(clip: StringName) -> void:
	deployed = clip == _clips.get(true, &"")
	target_deployed = deployed
	moving = false
	deployment_changed.emit(deployed)

func get_status() -> String:
	return "DEPLOYING" if moving and target_deployed else "STOWING" if moving else "DEPLOYED" if deployed else "STOWED"

func get_camera_texture() -> Texture2D:
	return _viewport.get_texture() if _viewport != null else null

func _process(delta: float) -> void:
	if _viewport == null:
		return
	_elapsed += delta
	if _elapsed >= 1.0 / maxf(camera_refresh_hz, 1.0):
		_elapsed = 0.0
		_camera.global_transform = _mount.global_transform
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
