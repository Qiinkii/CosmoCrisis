extends CanvasLayer

@onready var prompt_label: Label = $PromptLabel
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var co2_label: Label = $MarginContainer/VBoxContainer/CO2Label
@onready var pressure_label: Label = $MarginContainer/VBoxContainer/PressureLabel

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	ShipTelemetryGlobal.telemetry_updated.connect(_on_telemetry_updated)

func _on_prompt_changed(prompt_visible: bool, text: String) -> void:
	prompt_label.visible = prompt_visible
	prompt_label.text = "[E] " + text

func _on_telemetry_updated() -> void:
	progress_label.text = "ПОЛІТ: %.1f%%" % ShipTelemetryGlobal.flight_progress
	co2_label.text = "CO2: %.2f%%" % ShipTelemetryGlobal.co2_level
	pressure_label.text = "ТИСК (КАБ / ІНЖ): %.1f / %.1f кПа" % [
		ShipTelemetryGlobal.cockpit_pressure,
		ShipTelemetryGlobal.engineering_pressure
	]
