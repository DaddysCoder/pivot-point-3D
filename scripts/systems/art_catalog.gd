class_name ArtCatalog
extends RefCounted
## Runtime paths for the locked concept pack + generated UI art.


const CHAR_SELECT := "res://assets/art/01-character-selection.jpg"
const WORLD_MAP := "res://assets/art/02-world-map-oakhaven.jpg"
const ICON_SHEET := "res://assets/art/03-icon-sheet.jpg"
const EVENT_SHEET := "res://assets/art/04-event-card-sheet.jpg"
const BRIDGE_NARRATIVE := "res://assets/art/05-event-bridge-destroyed-a.jpg"
const BRIDGE_CHOICES := "res://assets/art/06-event-bridge-destroyed-b.jpg"
const PARCHMENT_PANEL := "res://assets/ui/parchment-panel.png"
const APP_ICON := "res://assets/ui/pivot-point-icon.png"

## Palette — parchment / wood / gold (matches concept UI)
const INK := Color(0.18, 0.12, 0.08, 1)
const INK_MUTED := Color(0.35, 0.28, 0.18, 1)
const PARCHMENT := Color(0.93, 0.86, 0.72, 1)
const WOOD := Color(0.28, 0.18, 0.10, 1)
const GOLD := Color(0.72, 0.55, 0.28, 1)
const DANGER := Color(0.55, 0.16, 0.12, 1)


static func texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


static func event_art(event_id: String) -> Texture2D:
	match event_id:
		"bridge-destroyed":
			return texture(BRIDGE_CHOICES)
		"supplies-delayed", "scout-missing", "weather-changes", "new-information", "ally-offers-help":
			return texture(EVENT_SHEET)
		_:
			return texture(BRIDGE_NARRATIVE)


static func apply_parchment_panel(panel: PanelContainer) -> void:
	var sb := StyleBoxTexture.new()
	var tex := texture(PARCHMENT_PANEL)
	if tex:
		sb.texture = tex
		sb.texture_margin_left = 48
		sb.texture_margin_top = 48
		sb.texture_margin_right = 48
		sb.texture_margin_bottom = 48
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = PARCHMENT
		flat.border_color = WOOD
		flat.set_border_width_all(4)
		flat.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", flat)
		return
	panel.add_theme_stylebox_override("panel", sb)


static func style_ink_label(label: Label, size: int = 18, muted: bool = false) -> void:
	label.add_theme_color_override("font_color", INK_MUTED if muted else INK)
	label.add_theme_font_size_override("font_size", size)


static func style_button(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.86, 0.76, 0.58, 1)
	normal.border_color = WOOD
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(3)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.92, 0.84, 0.66, 1)
	hover.border_color = GOLD
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.70, 0.65, 0.55, 1)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", INK)
	btn.add_theme_color_override("font_hover_color", INK)
	btn.add_theme_color_override("font_pressed_color", INK)
	btn.add_theme_color_override("font_disabled_color", INK_MUTED)
