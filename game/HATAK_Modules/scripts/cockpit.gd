extends Node3D
## Only this module is controlled. Existing project scripts are never modified.
signal throttle_changed(engine: int, value: float)
signal switch_changed(switch_name: String, enabled: bool)
signal auxiliary_button_pressed(button: String)
signal radiator_requested(side: String, deployed: bool)

@export_node_path("Node3D") var left_radiator_path: NodePath
@export_node_path("Node3D") var right_radiator_path: NodePath
@export var auto_use_existing_interactable := true
@export var enable_keyboard_interaction := true
@export var show_control_hint := true
@export var interaction_distance := 2.6
@export_node_path("Node") var telemetry_source_path := NodePath("/root/ShipTelemetryGlobal")
## Optional adapter to the supplied project's existing flight_speed property.
## This controls mission progress, not physical engine thrust or ship motion.
@export var drive_existing_flight_speed := false
@export var full_power_flight_speed := 0.5

var throttles: Array[float] = [0.0, 0.0]
var engine_telemetry: Array[Dictionary] = [{}, {}]
var thermal_telemetry: Dictionary = {}
var switches := {"Nav": false, "RCS": false, "Alarm": false, "Power": false}
var radiators: Dictionary = {}
var _source: AnimationPlayer
var _animation_players: Dictionary = {}
var _native_interaction := false
var _aimed_action := ""
var _hint: Label
var _panels: Array[Control] = []
var _feeds: Dictionary = {}
var _telemetry: Node
var _refresh_time := 0.0

class InstrumentPanel extends Control:
	var deck
	var mode := "engines"
	var side := "L"
	var font: Font = ThemeDB.fallback_font
	var ink := Color("c6d5cf")
	var muted := Color("526766")
	func text_at(pos: Vector2, message: String, color: Color, font_size: int = 17) -> void:
		draw_string(font, pos, message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	func _draw() -> void:
		if deck == null:
			return
		if mode == "camera":
			if deck.radiator_status(side) == "NO LINK":
				draw_rect(Rect2(0, 0, 512, 384), Color("070b0e"))
				text_at(Vector2(135, 205), "CAMERA NOT LINKED", muted, 21)
			draw_rect(Rect2(0, 0, 512, 35), Color(0.015, 0.025, 0.03, 0.93))
			draw_rect(Rect2(0, 350, 512, 34), Color(0.015, 0.025, 0.03, 0.93))
			var col := Color("65cbdc") if side == "L" else Color("c477d5")
			text_at(Vector2(13, 24), "CAM 01 / PORT" if side == "L" else "CAM 02 / STARBOARD", col, 19)
			var status: String = deck.radiator_status(side)
			text_at(Vector2(14, 373), "RADIATOR " + side + "  /  " + status, ink, 18)
			return
		draw_rect(Rect2(Vector2.ZERO, size), Color("070b0e"))
		draw_rect(Rect2(5, 5, size.x - 10, size.y - 10), muted, false, 2)
		if mode == "engines":
			text_at(Vector2(20, 33), "PROPULSION / ENGINE STATUS", ink, 21)
			draw_line(Vector2(18, 47), Vector2(622, 47), muted, 2)
			for i in range(2):
				var x := 20.0 + i * 310.0
				var col := Color("65cbdc") if i == 0 else Color("e2b84d")
				draw_rect(Rect2(x, 62, 290, 172), muted, false, 2)
				text_at(Vector2(x + 12, 94), "ENGINE " + str(i + 1), col, 21)
				text_at(Vector2(x + 12, 129), "THROTTLE   %03d %%" % roundi(deck.throttles[i] * 100.0), ink, 19)
				var data: Dictionary = deck.engine_telemetry[i]
				text_at(Vector2(x + 12, 162), "RPM   " + ("%.0f" % float(data.rpm) if data.has("rpm") else "---"), ink, 16)
				text_at(Vector2(x + 12, 190), "TEMP  " + ("%.1f C" % float(data.temperature_c) if data.has("temperature_c") else "NO SENSOR"), muted, 16)
				draw_rect(Rect2(x + 13, 208, 261, 13), muted, false, 1)
				draw_rect(Rect2(x + 15, 210, 257 * deck.throttles[i], 9), col)
		elif mode == "navigation":
			text_at(Vector2(20, 34), "NAVIGATION / SHIP", ink, 22)
			text_at(Vector2(24, 96), "FLIGHT   " + deck.telemetry_text("get_flight_progress", " %"), ink, 24)
			text_at(Vector2(24, 163), "CABIN PRESSURE", muted, 20)
			text_at(Vector2(24, 207), deck.telemetry_text("get_cockpit_pressure", " kPa"), ink, 28)
			text_at(Vector2(24, 273), "ENGINEERING PRESSURE", muted, 20)
			text_at(Vector2(24, 317), deck.telemetry_text("get_engineering_pressure", " kPa"), ink, 28)
			text_at(Vector2(24, 397), "CO2   " + deck.telemetry_text("get_co2_level", " %", 2), ink, 22)
			text_at(Vector2(24, 465), "LIVE SHIP TELEMETRY" if deck._telemetry != null else "TELEMETRY NOT LINKED", muted, 17)
		elif mode == "thermal":
			text_at(Vector2(20, 34), "THERMAL / TEMPERATURE", ink, 22)
			for i in range(2):
				var x := 22.0 + i * 247.0
				var sd := "L" if i == 0 else "R"
				var col := Color("65cbdc") if i == 0 else Color("c477d5")
				draw_rect(Rect2(x, 70, 220, 115), muted, false, 2)
				text_at(Vector2(x + 12, 98), "PORT" if i == 0 else "STARBOARD", col, 18)
				var value: String = "%.1f C" % float(deck.thermal_telemetry[sd]) if deck.thermal_telemetry.has(sd) else "--.- C"
				text_at(Vector2(x + 10, 151), value, ink, 35)
				var status: String = deck.radiator_status(sd)
				text_at(Vector2(24, 259 + i * 52), "RADIATOR " + sd + "   " + status, col, 22)
			text_at(Vector2(24, 389), "INDEPENDENT THERMAL LOOPS", ink, 19)
			text_at(Vector2(24, 438), "SENSOR DATA: " + ("ONLINE" if not deck.thermal_telemetry.is_empty() else "NOT CONNECTED"), muted, 17)

func _ready() -> void:
	_source = find_child("AnimationPlayer", true, false) as AnimationPlayer
	_native_interaction = auto_use_existing_interactable and ClassDB.class_exists("Interactable") and ClassDB.can_instantiate("Interactable")
	if not telemetry_source_path.is_empty():
		_telemetry = get_node_or_null(telemetry_source_path)
	for mesh in find_children("*", "MeshInstance3D", true, false):
		var action := _mesh_action(str(mesh.name))
		if action != "":
			_add_interaction(mesh, action)
	_add_instrument("Screen_Engines", "engines", Vector2i(640, 256))
	_add_instrument("Screen_Thermal", "thermal", Vector2i(512, 512))
	_add_instrument("Screen_Navigation", "navigation", Vector2i(512, 576))
	if show_control_hint and not _native_interaction:
		var ui := CanvasLayer.new()
		ui.layer = 15
		add_child(ui)
		_hint = Label.new()
		_hint.position = Vector2(22, 78)
		_hint.add_theme_font_size_override("font_size", 17)
		ui.add_child(_hint)
	_finish_links.call_deferred()
	set_thermal_telemetry(21.0, 24.5)

func _finish_links() -> void:
	await get_tree().process_frame
	for side in ["L", "R"]:
		var path := left_radiator_path if side == "L" else right_radiator_path
		var radiator := get_node_or_null(path) if not path.is_empty() else null
		if radiator != null and radiator.has_method("set_deployed") and radiator.has_method("get_camera_texture"):
			radiators[side] = radiator
		_add_camera_screen(side)
	if drive_existing_flight_speed and _telemetry != null and _telemetry.has_method("get_flight_speed"):
		var initial := clampf(float(_telemetry.call("get_flight_speed")) / maxf(full_power_flight_speed, 0.001), 0.0, 1.0)
		# Assign both before emitting, avoiding a temporary half-throttle command.
		throttles = [initial, initial]
		set_throttle(1, initial)
		set_throttle(2, initial)

func _mesh_action(id: String) -> String:
	for side in ["L", "R"]:
		if id == "Radiator_" + side + "_Button":
			return "radiator_" + side
	for i in [1, 2]:
		if id == "Throttle_" + str(i) + "_Grip":
			return "throttle_" + str(i)
	for id_switch in switches:
		if id == "Switch_" + id_switch + "_Paddle":
			return "switch_" + id_switch
	for button in ["Nav", "RCS", "Comms", "Aux", "Alarm", "Power"]:
		if id == "Button_" + button:
			return "aux_" + button
	return ""

func _add_interaction(mesh: MeshInstance3D, action: String) -> void:
	var area: Area3D = ClassDB.instantiate("Interactable") as Area3D if _native_interaction else Area3D.new()
	area.name = "ModuleInteraction"
	area.collision_layer = 2 if _native_interaction else 1 << 18
	area.collision_mask = 0
	area.monitoring = false
	area.set_meta("hatak_module", self)
	area.set_meta("hatak_action", action)
	if _native_interaction:
		area.set("prompt_text", prompt_for(action))
		area.set("is_pickup", false)
		area.connect("interacted", _on_existing_interaction.bind(action))
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	var bounds := mesh.get_aabb()
	box.size = bounds.size.max(Vector3.ONE * 0.008) + Vector3.ONE * 0.012
	shape.shape = box
	shape.position = bounds.get_center()
	area.add_child(shape)
	mesh.add_child(area)

func _on_existing_interaction(player: Node, action: String) -> void:
	if player != null and player.has_method("get_can_move") and not player.call("get_can_move"):
		return
	interact(action, -0.1 if Input.is_physical_key_pressed(KEY_SHIFT) else 0.1)

func interact(action: String, step := 0.1) -> void:
	if action.begins_with("radiator_"):
		var side := action.right(1)
		if radiators.has(side) and is_instance_valid(radiators[side]):
			var radiator: Node = radiators[side]
			var target := not bool(radiator.get("target_deployed"))
			radiator.call("set_deployed", target)
			radiator_requested.emit(side, target)
		_play_control("radiator_" + side, "Radiator_" + side + "_Button_Press")
	elif action.begins_with("throttle_"):
		var engine := int(action.right(1))
		set_throttle(engine, throttles[engine - 1] + step)
	elif action.begins_with("switch_"):
		var id := action.trim_prefix("switch_")
		if switches.has(id):
			set_switch(id, not switches[id])
	elif action.begins_with("aux_"):
		var button := action.trim_prefix("aux_")
		_play_control("aux_" + button, "Button_" + button + "_Press")
		auxiliary_button_pressed.emit(button)

func set_switch(id: String, enabled: bool) -> void:
	if not switches.has(id) or switches[id] == enabled:
		return
	switches[id] = enabled
	_play_control("switch_" + id, "Switch_" + id + ("_On" if enabled else "_Off"))
	switch_changed.emit(id, enabled)

func _play_control(key: String, clip: String) -> void:
	if _source == null or not _source.has_animation(clip):
		return
	if not _animation_players.has(key):
		var ap := AnimationPlayer.new()
		ap.name = "Control_" + key
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
		add_child(ap)
		ap.root_node = ap.get_path_to(_source.get_node(_source.root_node))
		ap.add_animation_library("", AnimationLibrary.new())
		_animation_players[key] = ap
	var player: AnimationPlayer = _animation_players[key]
	var lib := player.get_animation_library("")
	if not lib.has_animation(clip):
		lib.add_animation(clip, _source.get_animation(clip))
	player.play(clip, 0.06)

func set_throttle(engine: int, value: float) -> void:
	if engine < 1 or engine > 2:
		return
	throttles[engine - 1] = clampf(value, 0.0, 1.0)
	var lever := find_child("Throttle_" + str(engine) + "_Pivot", true, false) as Node3D
	if lever != null:
		lever.rotation.x = deg_to_rad(lerpf(30.0, -35.0, throttles[engine - 1]))
	if drive_existing_flight_speed and _telemetry != null and _telemetry.has_method("set_flight_speed"):
		_telemetry.call("set_flight_speed", (throttles[0] + throttles[1]) * 0.5 * full_power_flight_speed)
	throttle_changed.emit(engine, throttles[engine - 1])
	_refresh()

func set_engine_telemetry(engine: int, rpm: float, temperature_c: float) -> void:
	if engine >= 1 and engine <= 2:
		engine_telemetry[engine - 1] = {"rpm": rpm, "temperature_c": temperature_c}
		_refresh()

func set_thermal_telemetry(left_c: float, right_c: float) -> void:
	thermal_telemetry = {"L": left_c, "R": right_c}
	_refresh()

func telemetry_text(method: String, suffix: String, digits := 1) -> String:
	if not is_instance_valid(_telemetry) or not _telemetry.has_method(method):
		return "---" + suffix
	return ("%.*f" % [digits, float(_telemetry.call(method))]) + suffix

func radiator_status(side: String) -> String:
	return str(radiators[side].call("get_status")) if radiators.has(side) and is_instance_valid(radiators[side]) else "NO LINK"

func _screen_material(surface: MeshInstance3D, texture: Texture2D) -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = texture
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	surface.set_surface_override_material(0, mat)

func _add_instrument(node_name: String, mode: String, resolution: Vector2i) -> void:
	var surface := find_child(node_name, true, false) as MeshInstance3D
	if surface == null:
		return
	var vp := SubViewport.new()
	vp.name = node_name + "_UI"
	vp.size = resolution
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var panel := InstrumentPanel.new()
	panel.deck = self
	panel.mode = mode
	panel.size = Vector2(resolution)
	vp.add_child(panel)
	_panels.append(panel)
	_screen_material(surface, vp.get_texture())

func _add_camera_screen(side: String) -> void:
	var surface := find_child("Screen_Radiator_" + side, true, false) as MeshInstance3D
	if surface == null:
		return
	var vp := SubViewport.new()
	vp.name = "Screen_Camera_" + side
	vp.size = Vector2i(512, 384)
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var feed := TextureRect.new()
	feed.size = Vector2(512, 384)
	feed.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	feed.stretch_mode = TextureRect.STRETCH_SCALE
	if radiators.has(side):
		feed.texture = radiators[side].call("get_camera_texture")
	vp.add_child(feed)
	_feeds[side] = feed
	var overlay := InstrumentPanel.new()
	overlay.deck = self
	overlay.mode = "camera"
	overlay.side = side
	overlay.size = Vector2(512, 384)
	vp.add_child(overlay)
	_panels.append(overlay)
	_screen_material(surface, vp.get_texture())

func _sync_camera_links() -> void:
	# Resolve again: separately instanced radiators may enter the tree later.
	for side in ["L", "R"]:
		var path := left_radiator_path if side == "L" else right_radiator_path
		var radiator := get_node_or_null(path) if not path.is_empty() else null
		var texture: Texture2D = null
		if radiator != null and radiator.has_method("set_deployed") and radiator.has_method("get_camera_texture"):
			radiators[side] = radiator
			texture = radiator.call("get_camera_texture")
		else:
			radiators.erase(side)
		if _feeds.has(side) and is_instance_valid(_feeds[side]):
			if _feeds[side].texture != texture:
				_feeds[side].texture = texture

func _refresh() -> void:
	_sync_camera_links()
	for panel in _panels:
		panel.queue_redraw()

func _process(delta: float) -> void:
	_refresh_time += delta
	if _refresh_time >= 0.1:
		_refresh_time = 0.0
		_refresh()
	if _hint != null:
		_hint.text = prompt_for(_aimed_action) if _aimed_action != "" else ""

func _physics_process(_delta: float) -> void:
	_aimed_action = ""
	if not enable_keyboard_interaction:
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_basis.z * interaction_distance)
	query.collide_with_areas = true
	var excluded: Array[RID] = []
	var ancestor: Node = camera
	while ancestor != null:
		if ancestor.has_method("get_can_move") and not ancestor.call("get_can_move"):
			return
		if ancestor is CollisionObject3D:
			excluded.append(ancestor.get_rid())
		ancestor = ancestor.get_parent()
	query.exclude = excluded
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider.has_meta("hatak_module") and hit.collider.get_meta("hatak_module") == self:
		_aimed_action = str(hit.collider.get_meta("hatak_action", ""))

func _unhandled_input(event: InputEvent) -> void:
	if not enable_keyboard_interaction or _aimed_action == "":
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E and not _native_interaction:
		interact(_aimed_action, -0.1 if event.shift_pressed else 0.1)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and _aimed_action.begins_with("throttle_") and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		interact(_aimed_action, 0.05 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.05)
		get_viewport().set_input_as_handled()

func prompt_for(action: String) -> String:
	if action.begins_with("radiator_"):
		return "Радиатор " + action.right(1) + " — раскрыть / сложить"
	if action.begins_with("throttle_"):
		return "РУД " + action.right(1) + " — колесо или E / Shift+E"
	if action.begins_with("switch_"):
		return "Тумблер " + action.trim_prefix("switch_") + " — вкл. / выкл."
	return action.trim_prefix("aux_")
