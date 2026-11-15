extends Control
## Main menu: start the mission, change basic settings, or quit.
##
## ShipTelemetryGlobal is an autoload and starts with is_mission_active = true,
## so while the menu is open the telemetry is held inactive. It is reset (which
## also re-activates it) right before the game scene is loaded.

const GAME_SCENE := "res://scenes/ship.tscn"
const SETTINGS_PATH := "user://settings.cfg"
const DEFAULT_LANGUAGE := "uk"

@onready var main_box: VBoxContainer = %MainBox
@onready var settings_box: VBoxContainer = %SettingsBox
@onready var title_label: Label = $Margin/Content/TitleLabel
@onready var subtitle_label: Label = $Margin/Content/SubtitleLabel
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var volume_slider: HSlider = %VolumeSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var back_button: Button = %BackButton
@onready var settings_title: Label = %SettingsTitle
@onready var volume_label: Label = %VolumeLabel
@onready var language_label: Label = %LanguageLabel
@onready var language_option: OptionButton = %LanguageOption

var telemetry: Node = null
var _is_starting: bool = false

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	telemetry = get_node_or_null("/root/ShipTelemetryGlobal")
	if telemetry != null:
		telemetry.set("is_mission_active", false)

	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_show_settings.bind(true))
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_show_settings.bind(false))
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	language_option.item_selected.connect(_on_language_changed)

	_configure_language_options()
	_load_settings()
	_apply_locale_texts()
	start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if settings_box.visible and event.is_action_pressed("ui_cancel"):
		_show_settings(false)
		get_viewport().set_input_as_handled()

func _configure_language_options() -> void:
	language_option.clear()
	language_option.add_item("Українська")
	language_option.add_item("English")

func _apply_locale_texts() -> void:
	title_label.text = "COSMOCRISIS"
	subtitle_label.text = Localization.tr("menu.subtitle")
	start_button.text = Localization.tr("menu.start")
	settings_button.text = Localization.tr("menu.settings")
	quit_button.text = Localization.tr("menu.quit")
	settings_title.text = Localization.tr("menu.settings_title")
	volume_label.text = Localization.tr("menu.volume")
	language_label.text = Localization.tr("menu.language")
	fullscreen_check.text = Localization.tr("menu.fullscreen")
	back_button.text = Localization.tr("menu.back")
	language_option.select(0 if Localization.current_language == "uk" else 1)

func _on_start_pressed() -> void:
	if _is_starting:
		return
	_is_starting = true
	start_button.disabled = true

	_reset_telemetry()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _show_settings(show_it: bool) -> void:
	settings_box.visible = show_it
	main_box.visible = not show_it
	if show_it:
		volume_slider.grab_focus()
	else:
		_save_settings()
		settings_button.grab_focus()

func _on_volume_changed(value: float) -> void:
	_apply_volume(value)

func _on_fullscreen_toggled(pressed: bool) -> void:
	_apply_fullscreen(pressed)

func _on_language_changed(index: int) -> void:
	var language_code := "uk" if index == 0 else "en"
	Localization.set_language(language_code)
	_apply_locale_texts()
	_save_settings()

func _apply_volume(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, value <= 0.001)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(value, 0.001)))

func _apply_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var volume := 1.0
	var fullscreen := false
	var language := DEFAULT_LANGUAGE
	if cfg.load(SETTINGS_PATH) == OK:
		volume = float(cfg.get_value("audio", "master_volume", 1.0))
		fullscreen = bool(cfg.get_value("video", "fullscreen", false))
		language = str(cfg.get_value("game", "language", DEFAULT_LANGUAGE))
	if language != "uk" and language != "en":
		language = DEFAULT_LANGUAGE

	volume_slider.set_value_no_signal(volume)
	fullscreen_check.set_pressed_no_signal(fullscreen)
	Localization.set_language(language)
	language_option.select(0 if language == "uk" else 1)
	_apply_volume(volume)
	_apply_fullscreen(fullscreen)

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", volume_slider.value)
	cfg.set_value("video", "fullscreen", fullscreen_check.button_pressed)
	cfg.set_value("game", "language", Localization.current_language)
	cfg.save(SETTINGS_PATH)

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
