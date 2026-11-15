extends RigidBody3D

@onready var telemetry: Node = get_node_or_null("/root/ShipTelemetryGlobal")
@onready var screen_mesh: MeshInstance3D = get_node_or_null("HATAK_Rugged_Tablet/Tablet_Screen_Display")

var _display: TabletDisplay

class TabletDisplay extends Control:
	var tel: Node
	var font: Font = ThemeDB.fallback_font
	var col_bg := Color("060b0e")
	var col_border := Color("2b4c54")
	var col_ink := Color("d5e8e4")
	var col_muted := Color("628388")
	var col_ok := Color("49d198")
	var col_warn := Color("ebb03d")
	var col_crit := Color("f04638")

	func _draw_text(pos: Vector2, msg: String, color: Color, size_px: int = 18) -> void:
		draw_string(font, pos, msg, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)

	func _draw_bar(rect: Rect2, ratio: float, fill_col: Color) -> void:
		draw_rect(rect, col_border, false, 2.0)
		var inner := rect.grow(-3.0)
		inner.size.x *= clampf(ratio, 0.0, 1.0)
		draw_rect(inner, fill_col)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), col_bg)
		draw_rect(Rect2(6, 6, size.x - 12, size.y - 12), col_border, false, 2.0)

		if tel == null:
			_draw_text(Vector2(24, 50), "NO TELEMETRY LINK", col_crit, 24)
			return

		var progress: float = float(tel.get("flight_progress"))
		var co2: float = float(tel.get("co2_level"))
		var temp: float = float(tel.get("air_temperature"))
		var p_cockpit: float = float(tel.get("cockpit_pressure"))
		var p_eng: float = float(tel.get("engineering_pressure"))
		var eclss_ok: bool = bool(tel.get("is_eclss_working"))
		var cool_ok: bool = bool(tel.get("is_cooling_system_working"))
		var breached: bool = bool(tel.get("is_hull_breached"))

		# Заголовок та прогрес польоту
		_draw_text(Vector2(20, 34), "HATAK TELEMETRY // ORBITAL", col_ink, 20)
		_draw_text(Vector2(360, 34), "FLIGHT %05.1f %%" % progress, col_ok, 20)
		draw_line(Vector2(18, 46), Vector2(size.x - 18, 46), col_border, 2.0)

		# 1. Тиск (Кокпіт і Інженерний відсік)
		var c_p_cockpit := col_crit if p_cockpit < 65.0 else (col_warn if p_cockpit < 90.0 else col_ink)
		var c_p_eng := col_crit if p_eng < 65.0 else (col_warn if p_eng < 90.0 else col_ink)
		_draw_text(Vector2(20, 78), "COCKPIT PRESS", col_muted, 15)
		_draw_text(Vector2(20, 104), "%.1f kPa" % p_cockpit, c_p_cockpit, 24)
		_draw_bar(Rect2(20, 114, 210, 14), p_cockpit / 101.3, c_p_cockpit)

		_draw_text(Vector2(270, 78), "ENG PRESS", col_muted, 15)
		_draw_text(Vector2(270, 104), "%.1f kPa" % p_eng, c_p_eng, 24)
		_draw_bar(Rect2(270, 114, 220, 14), p_eng / 101.3, c_p_eng)

		# 2. CO2 та Температура
		var c_co2 := col_crit if co2 > 1.2 else (col_warn if co2 > 0.4 else col_ink)
		var c_temp := col_crit if temp > 45.0 else (col_warn if temp > 30.0 else col_ink)
		_draw_text(Vector2(20, 162), "CO2 LEVEL", col_muted, 15)
		_draw_text(Vector2(20, 188), "%.2f %%" % co2, c_co2, 24)
		_draw_bar(Rect2(20, 198, 210, 14), co2 / 2.0, c_co2)

		_draw_text(Vector2(270, 162), "CABIN TEMP", col_muted, 15)
		_draw_text(Vector2(270, 188), "%.1f C" % temp, c_temp, 24)
		_draw_bar(Rect2(270, 198, 220, 14), (temp - 15.0) / 45.0, c_temp)

		# 3. Статуси систем знизу
		draw_line(Vector2(18, 232), Vector2(size.x - 18, 232), col_border, 2.0)
		_draw_text(Vector2(20, 260), "ECLSS: " + ("NOMINAL" if eclss_ok else "FAILURE!"), col_ok if eclss_ok else col_crit, 18)
		_draw_text(Vector2(270, 260), "COOLING: " + ("NOMINAL" if cool_ok else "FAILURE!"), col_ok if cool_ok else col_crit, 18)

		if breached:
			draw_rect(Rect2(20, 276, size.x - 40, 32), Color(0.55, 0.08, 0.08, 0.9))
			_draw_text(Vector2(95, 299), "! WARNING: HULL BREACH DETECTED !", Color(1, 0.9, 0.9), 18)
		else:
			_draw_text(Vector2(20, 298), "HULL INTEGRITY: SEALED", col_muted, 17)


func _ready() -> void:
	if screen_mesh == null:
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(512, 320) # Пропорція 1.6:1, точно під меш 0.248 x 0.155
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)

	_display = TabletDisplay.new()
	_display.tel = telemetry
	_display.size = Vector2(512, 320)
	vp.add_child(_display)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = vp.get_texture()
	screen_mesh.set_surface_override_material(0, mat)

	if telemetry != null and telemetry.has_signal("telemetry_updated"):
		telemetry.connect("telemetry_updated", _display.queue_redraw)

func _process(_delta: float) -> void:
	if _display != null:
		_display.queue_redraw()
