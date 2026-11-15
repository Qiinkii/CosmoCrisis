extends CanvasLayer

@onready var prompt_overlay: PanelContainer = $InteractionPrompt
@onready var prompt_label: Label = $InteractionPrompt/Content/PromptRow/PromptLabel
@onready var progress_ring: Control = $InteractionPrompt/Content/PromptRow/HoldKeyRing
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var co2_label: Label = $MarginContainer/VBoxContainer/CO2Label
@onready var temperature_label: Label = $MarginContainer/VBoxContainer/TemperatureLabel
@onready var pressure_label: Label = $MarginContainer/VBoxContainer/PressureLabel
@onready var ShipTelemetryGlobal: ShipTelemetry = get_node_or_null("/root/ShipTelemetryGlobal")

func _ready() -> void:
	prompt_overlay.visible = false
	var player := get_tree().get_first_node_in_group("player")
	if player:
		for conn in player.interaction_prompt_changed.get_connections():
			player.interaction_prompt_changed.disconnect(conn.callable)
		player.interaction_prompt_changed.connect(_on_prompt_changed)
	if ShipTelemetryGlobal != null:
		ShipTelemetryGlobal.telemetry_updated.connect(_on_telemetry_updated)
	_on_telemetry_updated()

func _on_prompt_changed(prompt_visible: bool, text: String, hold_progress: float) -> void:
	prompt_overlay.visible = prompt_visible
	prompt_label.visible = prompt_visible
	prompt_label.text = text
	progress_ring.progress = hold_progress

func _on_telemetry_updated() -> void:
	if ShipTelemetryGlobal == null:
		return
	progress_label.text = Localization.trf("hud.progress", [ShipTelemetryGlobal.flight_progress])
	co2_label.text = Localization.trf("hud.co2", [ShipTelemetryGlobal.co2_level])
	temperature_label.text = Localization.trf("hud.temperature", [ShipTelemetryGlobal.air_temperature])
	pressure_label.text = Localization.trf("hud.pressure", [
		ShipTelemetryGlobal.cockpit_pressure,
		ShipTelemetryGlobal.engineering_pressure
	])
