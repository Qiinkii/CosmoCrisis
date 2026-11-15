extends CanvasLayer

@onready var prompt_overlay: PanelContainer = $InteractionPrompt
@onready var prompt_label: Label = $InteractionPrompt/Content/PromptVBox/PromptLabel
@onready var interaction_bar: ProgressBar = $InteractionPrompt/Content/PromptVBox/InteractionBar
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var co2_label: Label = $MarginContainer/VBoxContainer/CO2Label
@onready var temperature_label: Label = $MarginContainer/VBoxContainer/TemperatureLabel
@onready var pressure_label: Label = $MarginContainer/VBoxContainer/PressureLabel
@onready var ShipTelemetryGlobal: ShipTelemetry = get_node_or_null("/root/ShipTelemetryGlobal")

func _ready() -> void:
	prompt_overlay.visible = false
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	if ShipTelemetryGlobal != null:
		ShipTelemetryGlobal.telemetry_updated.connect(_on_telemetry_updated)

func _on_prompt_changed(prompt_visible: bool, text: String, hold_progress: float) -> void:
	prompt_overlay.visible = prompt_visible
	prompt_label.visible = prompt_visible
	prompt_label.text = "[E] " + text
	interaction_bar.value = hold_progress
	interaction_bar.visible = prompt_visible

func _on_telemetry_updated() -> void:
	if ShipTelemetryGlobal == null:
		return
	progress_label.text = "ПОЛІТ: %.1f%%" % ShipTelemetryGlobal.flight_progress
	co2_label.text = "CO2: %.2f%%" % ShipTelemetryGlobal.co2_level
	temperature_label.text = "ТЕМПЕРАТУРА: %.1f°C" % ShipTelemetryGlobal.air_temperature
	pressure_label.text = "ТИСК (КАБ / ІНЖ): %.1f / %.1f кПа" % [
		ShipTelemetryGlobal.cockpit_pressure,
		ShipTelemetryGlobal.engineering_pressure
	]
