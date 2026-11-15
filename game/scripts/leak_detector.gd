extends RigidBody3D

@onready var screen_label: Label3D = $ScreenLabel
@onready var beep_player: AudioStreamPlayer3D = get_node_or_null("BeepPlayer")
@onready var telemetry: Node = get_node_or_null("/root/ShipTelemetryGlobal")

@export var max_scan_distance: float = 15.0
## Якщо прилад у руці повернутий носиком вгору, встанови true (використає +Y замість -Z)
@export var point_along_up_axis: bool = false

var beep_timer: float = 0.0
var wave_offset: float = 0.0

func _process(delta: float) -> void:
	if screen_label == null:
		return

	wave_offset += delta * 18.0

	if telemetry == null:
		screen_label.modulate = Color(1.0, 0.3, 0.2)
		screen_label.text = "ERR: NO TELEMETRY"
		return

	# Перевіряємо наявність пробоїни (підтримує і метод, і властивість C++ класу)
	var breached := false
	if telemetry.has_method("get_is_hull_breached"):
		breached = bool(telemetry.call("get_is_hull_breached"))
	elif "is_hull_breached" in telemetry:
		breached = bool(telemetry.get("is_hull_breached"))

	if not breached:
		_render_ready_screen()
		return

	var active_breach := _find_active_breach()
	if active_breach == null:
		screen_label.modulate = Color(1.0, 0.7, 0.2)
		screen_label.text = "ALR: HULL BREACH\nNO LOCAL SOURCE"
		return

	# Розрахунок відстані та напрямку до пробоїни
	var to_breach := active_breach.global_position - global_position
	var dist := maxf(to_breach.length(), 0.05)
	var dir_to_breach := to_breach / dist

	# Напрямок датчика (вперед від гравця -Z або вгору +Y)
	var sensor_dir := (global_transform.basis.y if point_along_up_axis else -global_transform.basis.z).normalized()
	var dot := sensor_dir.dot(dir_to_breach) # від -1.0 до 1.0
	var alignment := clampf((dot + 0.2) / 1.2, 0.0, 1.0)

	# 1. Близькість дає базовий сигнал до 45% (щоб знайти кімнату/відсік)
	var proximity := clampf(1.0 - (dist / max_scan_distance), 0.0, 1.0)
	# 2. Точне наведення підсилює сигнал до 100%
	var signal_strength := clampf(proximity * (0.45 + 0.55 * pow(alignment, 1.5)), 0.0, 1.0)
	var pct := int(round(signal_strength * 99.0))

	_render_active_screen(pct, signal_strength)
	_handle_audio(delta, signal_strength)


func _find_active_breach() -> Node3D:
	var active_id := -1
	if telemetry.has_method("get_active_breach_location"):
		active_id = int(telemetry.call("get_active_breach_location"))
	elif "active_breach_location" in telemetry:
		active_id = int(telemetry.get("active_breach_location"))

	# Шукаємо серед усіх вузлів у групі breach_points
	for node in get_tree().get_nodes_in_group("breach_points"):
		if not (node is Node3D):
			continue
		# Перевіряємо, чи вузол активний за ID, видимістю або методом/властивістю C++
		if active_id > 0 and "location_id" in node and int(node.get("location_id")) == active_id:
			return node
		if node.has_method("get_is_breached") and bool(node.call("get_is_breached")):
			return node
		if "is_breached" in node and bool(node.get("is_breached")):
			return node
		if node.visible and node is CollisionObject3D and node.collision_layer != 0:
			return node

	return null


func _render_ready_screen() -> void:
	screen_label.modulate = Color(0.4, 0.9, 0.8)
	var grid_text := ""
	for r in range(4):
		grid_text += "  |--------------|\n" if r == 3 else "  | . . . . . . .|\n"

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


func _render_active_screen(pct: int, signal_strength: float) -> void:
	if pct > 65:
		screen_label.modulate = Color(1.0, 0.3, 0.2) # Червоний (близько і точно наведено)
	elif pct > 30:
		screen_label.modulate = Color(1.0, 0.7, 0.2) # Жовтий (поруч)
	else:
		screen_label.modulate = Color(0.4, 0.9, 0.8) # Зелений (пошук)

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
	var status_text := "CRITICAL LEAK SOURCE!" if pct > 70 else ("LEAK DETECTED - AIM" if pct > 20 else "SEARCHING FOR LEAK...")

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


func _handle_audio(delta: float, signal_strength: float) -> void:
	# Звук працює, коли детектор у руці (HandSlot)
	if get_parent() == null or get_parent().name != "HandSlot":
		return
	if beep_player == null or beep_player.stream == null:
		return

	beep_timer -= delta
	if beep_timer <= 0.0:
		beep_timer = clampf(1.1 - signal_strength * 1.0, 0.08, 1.1)
		beep_player.pitch_scale = 0.85 + signal_strength * 0.45
		beep_player.play()
