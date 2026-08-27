extends Control
## After Action report — parchment dossier.


@onready var panel: PanelContainer = $Panel
@onready var body: Label = $Panel/Margin/VBox/Body
@onready var hub_btn: Button = $Panel/Margin/VBox/ReturnHub
@onready var bg: TextureRect = $BgArt


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tex := ArtCatalog.texture(ArtCatalog.WORLD_MAP)
	if tex:
		bg.texture = tex
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(body, 16)
	ArtCatalog.style_button(hub_btn)
	hub_btn.pressed.connect(func(): SceneRouter.to_base_hub())
	var s: Dictionary = GameState.last_after_action
	if s.is_empty():
		body.text = "No mission summary."
		return
	var lines: PackedStringArray = PackedStringArray([
		"AFTER ACTION — SUPPLY LINE",
		"",
		"Leader: %s" % str(s.get("leader", "")),
		"Route: %s" % str(s.get("route", "")),
		"Turns: %d" % int(s.get("turns", 0)),
		"Pivots faced: %d" % int(s.get("pivots", 0)),
		"Materials left: %d · Intel: %d" % [int(s.get("materials", 0)), int(s.get("intel", 0))],
		"",
		"Log:",
	])
	for line in s.get("log", []):
		lines.append("• %s" % str(line))
	body.text = "\n".join(lines)
	GameState.clear_mission()
