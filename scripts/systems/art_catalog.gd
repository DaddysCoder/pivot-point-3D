class_name ArtCatalog
extends RefCounted
## Runtime paths for the locked concept pack + generated UI art.


const CHAR_SELECT := "res://assets/art/01-character-selection.jpg"
const WORLD_MAP := "res://assets/art/02-world-map-oakhaven.jpg"
const ICON_SHEET := "res://assets/art/03-icon-sheet.jpg"
const EVENT_SHEET := "res://assets/art/04-event-card-sheet.jpg"
const BRIDGE_NARRATIVE := "res://assets/art/05-event-bridge-destroyed-a.jpg"
const BRIDGE_CHOICES := "res://assets/art/06-event-bridge-destroyed-b.jpg"

## Event art pairs (narrative / choice card) from the Gemini event sheet.
## Narrative cards for all 5 events are in; choice cards for Scout Missing,
## Weather Changes, New Information, and Ally Offers Help still need a clean
## regen (current renders have titles/labels painted into the art) — those
## constants point at files not yet on disk, and texture()/event_art() fall
## back to EVENT_SHEET until they land.
const SUPPLIES_DELAYED_NARRATIVE := "res://assets/art/07-event-supplies-delayed-a.jpg"
const SUPPLIES_DELAYED_CHOICES := "res://assets/art/07-event-supplies-delayed-b.jpg"
const SCOUT_MISSING_NARRATIVE := "res://assets/art/08-event-scout-missing-a.jpg"
const SCOUT_MISSING_CHOICES := "res://assets/art/08-event-scout-missing-b.jpg"
const WEATHER_CHANGES_NARRATIVE := "res://assets/art/09-event-weather-changes-a.jpg"
const WEATHER_CHANGES_CHOICES := "res://assets/art/09-event-weather-changes-b.jpg"
const NEW_INFORMATION_NARRATIVE := "res://assets/art/10-event-new-information-a.jpg"
const NEW_INFORMATION_CHOICES := "res://assets/art/10-event-new-information-b.jpg"
const ALLY_OFFERS_HELP_NARRATIVE := "res://assets/art/11-event-ally-offers-help-a.jpg"
const ALLY_OFFERS_HELP_CHOICES := "res://assets/art/11-event-ally-offers-help-b.jpg"

## Front-facing leader portraits (character creator confirm/preview panel).
const LEADER_PORTRAIT_MARCUS := "res://assets/art/12-leader-marcus.png"
const LEADER_PORTRAIT_LI := "res://assets/art/13-leader-li.png"
const LEADER_PORTRAIT_ELIAS := "res://assets/art/14-leader-elias.png"
const LEADER_PORTRAIT_AMINA := "res://assets/art/15-leader-amina.png"
const LEADER_PORTRAIT_ELARA := "res://assets/art/16-leader-elara.png"
const LEADER_PORTRAIT_KAEL := "res://assets/art/17-leader-kael.png"

## Play Style / accessibility icon set.
const ICON_PREDICTABILITY := "res://assets/art/18-icon-predictability.png"
const ICON_DECISION_LOAD := "res://assets/art/19-icon-decision-load.png"
const ICON_TIME_PRESSURE := "res://assets/art/20-icon-time-pressure.png"
const ICON_INFORMATION_DENSITY := "res://assets/art/21-icon-information-density.png"
const ICON_MOTION := "res://assets/art/22-icon-motion.png"
const ICON_SOUND := "res://assets/art/23-icon-sound.png"
const ICON_ACCESSIBILITY_MENU := "res://assets/art/24-icon-accessibility-menu.png"

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


## Returns the choice-card art for `event_id` (narrative_art() returns the
## matching narrative card). Falls back to the generic event sheet when the
## per-event PNG isn't present on disk yet.
static func event_art(event_id: String) -> Texture2D:
	match event_id:
		"bridge-destroyed":
			return texture(BRIDGE_CHOICES)
		"supplies-delayed":
			return texture(SUPPLIES_DELAYED_CHOICES) if ResourceLoader.exists(SUPPLIES_DELAYED_CHOICES) else texture(EVENT_SHEET)
		"scout-missing":
			return texture(SCOUT_MISSING_CHOICES) if ResourceLoader.exists(SCOUT_MISSING_CHOICES) else texture(EVENT_SHEET)
		"weather-changes":
			return texture(WEATHER_CHANGES_CHOICES) if ResourceLoader.exists(WEATHER_CHANGES_CHOICES) else texture(EVENT_SHEET)
		"new-information":
			return texture(NEW_INFORMATION_CHOICES) if ResourceLoader.exists(NEW_INFORMATION_CHOICES) else texture(EVENT_SHEET)
		"ally-offers-help":
			return texture(ALLY_OFFERS_HELP_CHOICES) if ResourceLoader.exists(ALLY_OFFERS_HELP_CHOICES) else texture(EVENT_SHEET)
		_:
			return texture(BRIDGE_NARRATIVE)


## Returns the narrative-card art for `event_id`. Falls back to the generic
## event sheet, then the Bridge Destroyed narrative card as a last resort.
static func narrative_art(event_id: String) -> Texture2D:
	match event_id:
		"bridge-destroyed":
			return texture(BRIDGE_NARRATIVE)
		"supplies-delayed":
			return texture(SUPPLIES_DELAYED_NARRATIVE) if ResourceLoader.exists(SUPPLIES_DELAYED_NARRATIVE) else texture(EVENT_SHEET)
		"scout-missing":
			return texture(SCOUT_MISSING_NARRATIVE) if ResourceLoader.exists(SCOUT_MISSING_NARRATIVE) else texture(EVENT_SHEET)
		"weather-changes":
			return texture(WEATHER_CHANGES_NARRATIVE) if ResourceLoader.exists(WEATHER_CHANGES_NARRATIVE) else texture(EVENT_SHEET)
		"new-information":
			return texture(NEW_INFORMATION_NARRATIVE) if ResourceLoader.exists(NEW_INFORMATION_NARRATIVE) else texture(EVENT_SHEET)
		"ally-offers-help":
			return texture(ALLY_OFFERS_HELP_NARRATIVE) if ResourceLoader.exists(ALLY_OFFERS_HELP_NARRATIVE) else texture(EVENT_SHEET)
		_:
			return texture(BRIDGE_NARRATIVE)


## Front-facing leader portrait for the character creator's confirm/preview
## panel. Returns null (caller falls back to the compact silhouette art)
## until the sliced portrait PNGs land in assets/art/.
static func leader_portrait(leader_id: String) -> Texture2D:
	match leader_id:
		"strategist":
			return texture(LEADER_PORTRAIT_MARCUS)
		"scout":
			return texture(LEADER_PORTRAIT_LI)
		"engineer":
			return texture(LEADER_PORTRAIT_ELIAS)
		"diplomat":
			return texture(LEADER_PORTRAIT_AMINA)
		"historian":
			return texture(LEADER_PORTRAIT_ELARA)
		"builder":
			return texture(LEADER_PORTRAIT_KAEL)
		_:
			return null


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
	_wire_hover_cursor(btn)


## Swaps in CursorManager's bolder hover cursor while the pointer is over
## `control`. Safe to call once per control; guards against leaving the
## hover depth stuck if the control leaves the tree mid-hover.
static func _wire_hover_cursor(control: Control) -> void:
	if control.has_meta("_hover_cursor_wired"):
		return
	control.set_meta("_hover_cursor_wired", true)
	var hovering := [false]
	control.mouse_entered.connect(func():
		hovering[0] = true
		CursorManager.push_hover())
	control.mouse_exited.connect(func():
		if hovering[0]:
			hovering[0] = false
			CursorManager.pop_hover())
	control.tree_exiting.connect(func():
		if hovering[0]:
			hovering[0] = false
			CursorManager.pop_hover())
