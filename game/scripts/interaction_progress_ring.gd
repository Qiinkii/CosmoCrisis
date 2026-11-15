extends Control

@export_range(0.0, 1.0, 0.01) var progress: float = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()

const RING_RADIUS := 13.0
const RING_WIDTH := 2.5
const START_ANGLE := -PI / 2.0

func _draw() -> void:
	var center := size * 0.5
	draw_arc(center, RING_RADIUS, 0.0, TAU, 48, Color(0.10, 0.16, 0.19, 1.0), RING_WIDTH, true)
	if progress > 0.0:
		draw_arc(center, RING_RADIUS, START_ANGLE, START_ANGLE + TAU * progress, 48, Color(0.28, 0.82, 0.91, 1.0), RING_WIDTH, true)
