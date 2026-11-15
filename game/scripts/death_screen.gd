extends CanvasLayer
## Mission failed overlay.

const FADE_DURATION := 1.5
const MAIN_MENU_SCENE := "res://ui/main_menu.tscn"

@onready var root: Control = %Root
@onready var title_label: Label = $Root/Center/Panel/Margin/Content/TitleLabel
@onready var subtitle_label: Label = $Root/Center/Panel/Margin/Content/SubtitleLabel
@onready var reason_label: Label = %ReasonLabel
@onready var stats_label: Label = %StatsLabel
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

var telemetry: Node = null
var _is_showing: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_apply_locale_texts()
	telemetry = get_node_or_null("/root/ShipTelemetryGlobal")
	if telemetry != null and telemetry.has_signal("mission_failed"):
		telemetry.connect("mission_failed", show_death_screen)

func _apply_locale_texts() -> void:
	title_label.text = Localization.translate_key("death.title")
	subtitle_label.text = Localization.translate_key("death.subtitle")
	restart_button.text = Localization.translate_key("death.restart")
	main_menu_button.text = Localization.translate_key("death.menu")
	quit_button.text = Localization.translate_key("death.quit")

func show_death_screen(reason: String) -> void:
	if _is_showing:
		return
	_is_showing = true
	var progress := 0.0
	if telemetry != null:
		progress = float(telemetry.get("flight_progress"))
	reason_label.text = reason
	stats_label.text = Localization.trf("death.progress", [progress])
	_apply_locale_texts()
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
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	restart_button.disabled = true
	main_menu_button.disabled = true
	quit_button.disabled = true
	_is_showing = false
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _reset_telemetry() -> void:
	if telemetry == null:
		return
	if telemetry.has_method("reset_mission"):
		telemetry.call("reset_mission")
		return
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
