extends Node
## Applies the high-visibility custom cursor everywhere and swaps in a
## bolder variant on hover, driven by GameSettings.cursor_size.

const VARIANTS := {
	GameSettings.CursorSize.STANDARD: {
		"base": "res://assets/ui/cursor/cursor_standard.png",
		"hover": "res://assets/ui/cursor/cursor_standard_hover.png",
		"hotspot": Vector2(6, 4),
	},
	GameSettings.CursorSize.LARGE: {
		"base": "res://assets/ui/cursor/cursor_large.png",
		"hover": "res://assets/ui/cursor/cursor_large_hover.png",
		"hotspot": Vector2(9, 6),
	},
}

var _hover_depth := 0


func _ready() -> void:
	GameSettings.cursor_size_changed.connect(_on_cursor_size_changed)
	apply()


func _on_cursor_size_changed(_size: GameSettings.CursorSize) -> void:
	apply()


func apply() -> void:
	_set_cursor("hover" if _hover_depth > 0 else "base")


func _set_cursor(key: String) -> void:
	var variant: Dictionary = VARIANTS[GameSettings.cursor_size]
	var tex := load(str(variant[key])) as Texture2D
	if tex:
		Input.set_custom_mouse_cursor(tex, Input.CURSOR_ARROW, variant["hotspot"])


## Called by ArtCatalog.style_button() hookups on hover enter/exit so any
## themed button gets the bolder cursor without per-scene wiring.
func push_hover() -> void:
	_hover_depth += 1
	apply()


func pop_hover() -> void:
	_hover_depth = max(0, _hover_depth - 1)
	apply()
