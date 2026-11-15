extends Area3D
@onready var ShipTelemetryGlobal: ShipTelemetry = get_node_or_null("/root/Ship/ShipTelemetry")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		ShipTelemetryGlobal.set_is_player_in_engineering(true)

func _on_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		ShipTelemetryGlobal.set_is_player_in_engineering(false)
