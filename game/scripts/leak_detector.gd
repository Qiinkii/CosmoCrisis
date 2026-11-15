extends RigidBody3D

@onready var screen_label: Label3D = $ScreenLabel
@onready var beep_player: AudioStreamPlayer3D = get_node_or_null("BeepPlayer")
@onready var telemetry = get_node_or_null("/root/ShipTelemetryGlobal")

var beep_timer: float = 0.0
var wave_offset: float = 0.0

func _process(delta: float) -> void:
	if screen_label == null:
		return

	wave_offset += delta * 18.0

	var breached := false
	if telemetry != null:
		breached = telemetry.is_hull_breached

	if not breached:
		screen_label.modulate = Color(0.4, 0.9, 0.8)

		var grid_text := ""
		for r in range(4):
			if r == 3:
				grid_text += "  |--------------|\n"
			else:
				grid_text += "  | . . . . . . .|\n"

		screen_label.text = (
			"LEAK SCANNER   RDY\n" +
			"───────────────────\n" +
			"SIGNAL  ULTRASONIC\n" +
			" 00 %   SCAN READY\n" +
			"        GAIN  AUTO\n" +
			"  +--------------+\n" +
			grid_text +
			"  +--------------+\n" +
			"  [..............]\n\n" +
			" POINT SENSOR AT HULL"
		)
		return

	var active_breach: Node3D = null
	for point in get_tree().get_nodes_in_group("breach_points"):
		if point is CollisionObject3D and point.collision_layer == 2:
			active_breach = point
			break

	if active_breach == null:
		return

	var to_breach := active_breach.global_position - global_position
	var dist := maxf(to_breach.length(), 0.05)
	var dir_to_breach := to_breach / dist

	var sensor_axis := (global_transform.basis.y - global_transform.basis.z).normalized()
	var alignment := clampf((sensor_axis.dot(dir_to_breach) + 0.3) / 1.3, 0.0, 1.0)

	var proximity := clampf(1.0 - (dist / 12.0), 0.0, 1.0)
	var signal_strength := clampf(proximity * (0.2 + 0.8 * alignment), 0.0, 1.0)
	var pct := int(round(signal_strength * 99.0))

	if pct > 60:
		screen_label.modulate = Color(1.0, 0.3, 0.2) # Червоний (небезпечно)
	elif pct > 25:
		screen_label.modulate = Color(1.0, 0.7, 0.2) # Жовтий
	else:
		screen_label.modulate = Color(0.4, 0.9, 0.8) # Зеленуватий

	# Генерація амплітуди хвилі для осцилографа
	var grid_text := ""
	for r in range(4):
		grid_text += "  |"
		for c in range(7):
			var wave_val := sin(c * 1.1 - wave_offset) * (signal_strength * 1.9)
			wave_val += (randf() - 0.5) * (signal_strength * 0.7)
			var target_row := clampi(2 - int(round(wave_val)), 0, 3)

			if target_row == r:
				grid_text += "=="
			elif r == 3:
				grid_text += "--"
			else:
				grid_text += " ."
		grid_text += "|\n"

	var bars_filled := int(round(signal_strength * 14.0))
	var bar_chars := "=".repeat(bars_filled) + ".".repeat(14 - bars_filled)
	var status_text := "LEAK DETECTED - SEARCH" if pct > 10 else "SEARCHING FOR LEAK..."

	screen_label.text = (
		"LEAK SCANNER   ALR\n" +
		"───────────────────\n" +
		"SIGNAL  ULTRASONIC\n" +
		" %02d %%  SCAN ACTIVE\n" % pct +
		"        GAIN  AUTO\n" +
		"  +--------------+\n" +
		grid_text +
		"  +--------------+\n" +
		"  [" + bar_chars + "]\n\n" +
		status_text
	)

	if get_parent() != null and get_parent().name == "HandSlot":
		beep_timer -= delta
		if beep_timer <= 0.0:
			beep_timer = clampf(1.15 - signal_strength * 1.05, 0.08, 1.15)
			if beep_player != null and beep_player.stream != null:
				beep_player.pitch_scale = 0.85 + signal_strength * 0.4
				beep_player.play()
