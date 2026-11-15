extends Node3D

@onready var door_leaf: AnimatableBody3D = $DoorLeaf
@onready var panel_1: Interactable = $ControlPanel
@onready var panel_2: Interactable = $ControlPanel2
@onready var doorway_sensor: Area3D = $DoorWaySensor

const OPEN_Z := 0.0
const CLOSED_Z := 0.81
const MOVE_SPEED := 1

var is_doorway_blocked: bool = false

func _ready() -> void:
	door_leaf.position.z = CLOSED_Z if ShipTelemetryGlobal.is_bulkhead_closed else OPEN_Z
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

	var target_z := CLOSED_Z if ShipTelemetryGlobal.is_bulkhead_closed else OPEN_Z
	door_leaf.position.z = move_toward(door_leaf.position.z, target_z, MOVE_SPEED * delta)
