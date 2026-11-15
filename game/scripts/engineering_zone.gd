extends Area3D

@onready var ship_telemetry: ShipTelemetry = get_node_or_null("/root/ShipTelemetryGlobal")

func _on_body_entered(body: Node3D) -> void:
	if body is PlayerController and ship_telemetry != null:
		ship_telemetry.set_is_player_in_engineering(true)

func _on_body_exited(body: Node3D) -> void:
	if body is PlayerController and ship_telemetry != null:
		ship_telemetry.set_is_player_in_engineering(false)
