extends Control
## CHOOSE YOUR LEADER — concept hall + parchment roster.


@onready var bg: TextureRect = $BgArt
@onready var panel: PanelContainer = $Panel
@onready var grid: GridContainer = $Panel/Margin/VBox/Grid
@onready var detail: Label = $Panel/Margin/VBox/Detail
@onready var confirm: Button = $Panel/Margin/VBox/Confirm
@onready var title: Label = $Panel/Margin/VBox/Title
@onready var sub: Label = $Panel/Margin/VBox/Sub

var _selected: String = ""


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tex := ArtCatalog.texture(ArtCatalog.CHAR_SELECT)
	if tex:
		bg.texture = tex
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 26)
	ArtCatalog.style_ink_label(sub, 18, true)
	ArtCatalog.style_ink_label(detail, 16, true)
	ArtCatalog.style_button(confirm)
	confirm.disabled = true
	confirm.pressed.connect(_confirm)
	for leader in LeaderRegistry.list_all():
		var btn := Button.new()
		btn.text = "%s\n%s" % [leader["role"], leader["name"]]
		btn.custom_minimum_size = Vector2(160, 84)
		ArtCatalog.style_button(btn)
		var lid := str(leader["id"])
		btn.pressed.connect(func(): _select(lid))
		grid.add_child(btn)


func _select(leader_id: String) -> void:
	_selected = leader_id
	confirm.disabled = false
	for leader in LeaderRegistry.list_all():
		if leader["id"] == leader_id:
			detail.text = "%s — %s\n%s" % [leader["role"], leader["name"], leader["blurb"]]
			break


func _confirm() -> void:
	if _selected == "":
		return
	GameState.set_leader(_selected)
	LeaderRegistry.apply_starting_bonus(_selected)
	SceneRouter.to_base_hub()
