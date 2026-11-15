extends CanvasLayer

enum ValveDir { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3 }

@onready var t_handle: Control = $Panel/ValveDiagram/THandle
@onready var pipes: Array[ColorRect] = [
	$Panel/ValveDiagram/PipeUp,
	$Panel/ValveDiagram/PipeRight,
	$Panel/ValveDiagram/PipeDown,
	$Panel/ValveDiagram/PipeLeft
]
@onready var btn_up: Button = $Panel/ValveDiagram/CompassButtons/BtnUp
@onready var btn_right: Button = $Panel/ValveDiagram/CompassButtons/BtnRight
@onready var btn_down: Button = $Panel/ValveDiagram/CompassButtons/BtnDown
@onready var btn_left: Button = $Panel/ValveDiagram/CompassButtons/BtnLeft
@onready var confirm_btn: Button = $Panel/ConfirmButton
@onready var close_btn: Button = $Panel/CloseButton

const COLOR_PIPE_CLOSED := Color(0.25, 0.28, 0.32)
const COLOR_PIPE_OPEN := Color(0.2, 0.85, 0.55)

var current_dir: int = ValveDir.UP
var is_cartridge_swapped: bool = false

var current_player: PlayerController = null
var current_telemetry: ShipTelemetry = null
var current_terminal: EclssTerminal = null

func _ready() -> void:
	visible = false
	btn_up.pressed.connect(func(): _set_valve_dir(ValveDir.UP))
	btn_right.pressed.connect(func(): _set_valve_dir(ValveDir.RIGHT))
	btn_down.pressed.connect(func(): _set_valve_dir(ValveDir.DOWN))
	btn_left.pressed.connect(func(): _set_valve_dir(ValveDir.LEFT))
	confirm_btn.pressed.connect(_on_confirm_pressed)
	close_btn.pressed.connect(_on_close_pressed)
	_update_ui_state(true)

func open_repair_minigame(player: PlayerController, telemetry: ShipTelemetry, terminal: EclssTerminal = null) -> void:
	current_player = player
	current_telemetry = telemetry
	current_terminal = terminal
	
	if not is_cartridge_swapped:
		current_dir = ValveDir.UP
	_update_ui_state(true)
	visible = true

func _set_valve_dir(new_dir: int) -> void:
	if current_dir == new_dir:
		return
	current_dir = new_dir
	_update_ui_state(false)

func _update_ui_state(instant: bool) -> void:
	var target_angle: float = current_dir * 90.0
	if instant:
		t_handle.rotation_degrees = target_angle
	else:
		var tween := create_tween()
		tween.tween_property(t_handle, "rotation_degrees", target_angle, 0.18)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	for i in range(4):
		pipes[i].color = COLOR_PIPE_CLOSED if i == current_dir else COLOR_PIPE_OPEN

	if not is_cartridge_swapped:
		confirm_btn.disabled = (current_dir != ValveDir.RIGHT)
		confirm_btn.text = "Установить картридж LiOH" if current_dir == ValveDir.RIGHT else "Переведите кран в ISOLATE"
	else:
		confirm_btn.disabled = (current_dir != ValveDir.DOWN)
		confirm_btn.text = "Запустить очистку CO2" if current_dir == ValveDir.DOWN else "Переведите кран в LiOH"

func _on_confirm_pressed() -> void:
	if not is_cartridge_swapped and current_dir == ValveDir.RIGHT:
		if current_terminal != null:
			current_terminal.install_cartridge(current_player)
		elif current_player != null:
			current_player.clear_held_item()
		is_cartridge_swapped = true
		_update_ui_state(false)
		return

	if is_cartridge_swapped and current_dir == ValveDir.DOWN:
		if current_telemetry != null:
			current_telemetry.repair_co2_system()
		is_cartridge_swapped = false
		current_dir = ValveDir.UP
		_close_ui()

func _on_close_pressed() -> void:
	_close_ui()

func _close_ui() -> void:
	visible = false
	if current_player != null:
		current_player.can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
