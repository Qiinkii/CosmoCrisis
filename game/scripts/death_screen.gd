extends CanvasLayer
## Full-screen "mission failed" overlay.
##
## Registered as an autoload (see project.godot) so it keeps listening to
## ShipTelemetryGlobal across scene reloads. When the telemetry emits
## `mission_failed`, the game is paused, the overlay fades in and the player
## can restart the mission, return to the main menu or quit.

const FADE_DURATION := 1.5
const MAIN_MENU_SCENE := "res://ui/main_menu.tscn"

@onready var root: Control = %Root
@onready var reason_label: Label = %ReasonLabel
@onready var stats_label: Label = %StatsLabel
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

var telemetry: Node = null
var _is_showing: bool = false

func _ready() -> void:
	# Must keep running while the tree is paused (buttons, fade tween).
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	telemetry = get_node_or_null("/root/ShipTelemetryGlobal")
	if telemetry != null and telemetry.has_signal("mission_failed"):
		telemetry.connect("mission_failed", show_death_screen)

func show_death_screen(reason: String) -> void:
	if _is_showing:
		return
	_is_showing = true

	var progress: float = 0.0
	if telemetry != null:
		progress = float(telemetry.get("flight_progress"))

	reason_label.text = reason
	stats_label.text = "Пройдено шляху: %.1f%%" % progress

	# Block input until the fade has finished so a stray click can't skip it.
	restart_button.disabled = true
	main_menu_button.disabled = true
	quit_button.disabled = true

	root.modulate.a = 0.0
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 1.0, FADE_DURATION)
	tween.finished.connect(_on_fade_finished)

func _on_fade_finished() -> void:
	restart_button.disabled = false
	main_menu_button.disabled = false
	quit_button.disabled = false
	restart_button.grab_focus()

func _on_restart_pressed() -> void:
	restart_button.disabled = true
	main_menu_button.disabled = true
	quit_button.disabled = true

	_reset_telemetry()

	_is_showing = false
	visible = false
	get_tree().paused = false
	# The player's _ready() captures the mouse again after the reload.
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	restart_button.disabled = true
	main_menu_button.disabled = true
	quit_button.disabled = true

	_is_showing = false
	visible = false
	get_tree().paused = false
	# The main menu keeps the telemetry inactive and resets it on "Start".
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _reset_telemetry() -> void:
	if telemetry == null:
		return

	# ShipTelemetryGlobal is an autoload, so it survives reload_current_scene()
	# and would otherwise stay in its failed state.
	if telemetry.has_method("reset_mission"):
		telemetry.call("reset_mission")
		return

	# Fallback for a native library built before reset_mission() existed.
	# The private crisis-trigger flags cannot be reached from here, so crises
	# will not fire again until the extension is rebuilt.
	push_warning("ShipTelemetry.reset_mission() not found - rebuild the GDExtension for a full reset.")
	telemetry.set("co2_level", 0.04)
	telemetry.set("air_temperature", 22.0)
	telemetry.set("flight_progress", 0.0)
	telemetry.set("cockpit_pressure", 101.3)
	telemetry.set("engineering_pressure", 101.3)
	telemetry.set("is_eclss_working", true)
	telemetry.set("is_cooling_system_working", true)
	telemetry.set("is_hull_breached", false)
	telemetry.set("is_bulkhead_closed", false)
	telemetry.set("is_player_in_engineering", false)
	telemetry.set("is_mission_active", true)
