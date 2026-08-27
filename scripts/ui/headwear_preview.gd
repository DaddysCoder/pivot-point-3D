class_name HeadwearPreview
extends Control
## Small procedural operator-head icon for the headwear picker, mirroring the
## 2D reference's SVG silhouette (skin ellipse + headwear silhouette) so the
## preview stays live without needing bespoke bitmap art per option.

const SKIN := Color(0.769, 0.627, 0.478)
const DARK := Color(0.165, 0.188, 0.220)

var headwear: String = "none"
var cloth: Color = Color(0.353, 0.420, 0.271)


func set_state(new_headwear: String, new_cloth: Color) -> void:
	headwear = new_headwear
	cloth = new_cloth
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(24, 26), 12, SKIN)
	match headwear:
		"cap":
			draw_colored_polygon(PackedVector2Array([
				Vector2(12, 20), Vector2(24, 8), Vector2(36, 20), Vector2(40, 22), Vector2(8, 22)]), DARK)
		"helm":
			draw_colored_polygon(PackedVector2Array([
				Vector2(12, 22), Vector2(24, 6), Vector2(36, 22), Vector2(36, 28), Vector2(12, 28)]), DARK)
			draw_polyline(PackedVector2Array([
				Vector2(12, 22), Vector2(24, 6), Vector2(36, 22)]), cloth, 1.5)
		"visor":
			draw_rect(Rect2(14, 20, 20, 5), DARK)
		_:
			draw_polyline(PackedVector2Array([
				Vector2(14, 18), Vector2(24, 10), Vector2(34, 18)]), DARK, 3.0)
