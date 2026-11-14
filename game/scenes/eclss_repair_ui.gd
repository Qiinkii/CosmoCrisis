extends CanvasLayer

@onready var valve_a_btn: Button = $Panel/ValveAButton
@onready var valve_b_btn: Button = $Panel/ValveBButton
@onready var confirm_btn: Button = $Panel/ConfirmButton
@onready var close_btn: Button = $Panel/CloseButton

var valve_a_open: bool = false
var valve_b_open: bool = false

var current_player: PlayerController = null
var current_telemetry: ShipTelemetry = null

func _ready() -> void:
	visible = false
	valve_a_btn.pressed.connect(_on_valve_a_pressed)
	valve_b_btn.pressed.connect(_on_valve_b_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	close_btn.pressed.connect(_on_close_pressed)

func open_repair_minigame(player: PlayerController, telemetry: ShipTelemetry) -> void:
	current_player = player
	current_telemetry = telemetry
	
	valve_a_open = false
	valve_b_open = false
	_update_ui_state()
	visible = true

func _on_valve_a_pressed() -> void:
	valve_a_open = !valve_a_open
	_update_ui_state()

func _on_valve_b_pressed() -> void:
	valve_b_open = !valve_b_open
	_update_ui_state()

func _update_ui_state() -> void:
	valve_a_btn.text = "Клапан A (Впуск): " + ("ОТКРЫТ [OK]" if valve_a_open else "ЗАКРЫТ")
	valve_b_btn.text = "Клапан B (Выпуск): " + ("ОТКРЫТ [OK]" if valve_b_open else "ЗАКРЫТ")
	confirm_btn.disabled = not (valve_a_open and valve_b_open)

func _on_confirm_pressed() -> void:
	if current_player != null:
		current_player.clear_held_item()
	
	if current_telemetry != null:
		current_telemetry.repair_co2_system()
		
	_close_ui()

func _on_close_pressed() -> void:
	_close_ui()

func _close_ui() -> void:
	visible = false
	if current_player != null:
		current_player.can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
