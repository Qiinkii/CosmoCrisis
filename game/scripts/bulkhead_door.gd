extends Node3D

@onready var door_leaf: AnimatableBody3D = $DoorLeaf
@onready var panel_1: Interactable = $ControlPanel
@onready var panel_2: Interactable = $ControlPanel2
@onready var doorway_sensor: Area3D = $DoorWaySensor

const OPEN_Y := 2.4
const CLOSED_Y := 0.0
const MOVE_SPEED := 3.5

var is_doorway_blocked: bool = false

func _ready() -> void:
	door_leaf.position.y = CLOSED_Y if ShipTelemetryGlobal.is_bulkhead_closed else OPEN_Y
	panel_1.interacted.connect(_on_panel_interacted)
	panel_2.interacted.connect(_on_panel_interacted)

func _on_panel_interacted(_player: Node) -> void:
	if is_doorway_blocked:
		return
		
	var new_state: bool = not ShipTelemetryGlobal.is_bulkhead_closed
	ShipTelemetryGlobal.is_bulkhead_closed = new_state

func _physics_process(delta: float) -> void:
	# Перевіряємо всі фізичні тіла в зоні дверей (гравець, предмети тощо)
	var blocked := false
	for body in doorway_sensor.get_overlapping_bodies():
		if body is PlayerController or body is RigidBody3D:
			blocked = true
			break

	if blocked != is_doorway_blocked:
		is_doorway_blocked = blocked
		var text := "Clear the way through the airlock!" if is_doorway_blocked else "Switch door"
		panel_1.prompt_text = text
		panel_2.prompt_text = text

	var target_y := CLOSED_Y if ShipTelemetryGlobal.is_bulkhead_closed else OPEN_Y
	door_leaf.position.y = move_toward(door_leaf.position.y, target_y, MOVE_SPEED * delta)
