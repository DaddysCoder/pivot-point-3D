class_name SlotPicker
extends CanvasLayer
## "Who's playing?" slot picker. Reached from Boot's Begin button instead
## of silently starting or auto-resuming a single save — every campaign is
## explicitly bound to a named slot (call sign shown once character
## creation has run) so a table can share the game across sessions.

signal closed

static var current: SlotPicker = null

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/Outer/Title
@onready var subtitle: Label = $Panel/Margin/Outer/Subtitle
@onready var slot_list: VBoxContainer = $Panel/Margin/Outer/SlotList
@onready var close_btn: Button = $Panel/Margin/Outer/Close


static func open(parent: Node) -> SlotPicker:
	if current:
		return current
	var scene := load("res://scenes/ui/slot_picker.tscn") as PackedScene
	var picker := scene.instantiate() as SlotPicker
	current = picker
	parent.add_child(picker)
	return picker


func _ready() -> void:
	layer = 20
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 26)
	ArtCatalog.style_ink_label(subtitle, 13, true)
	ArtCatalog.style_button(close_btn)
	close_btn.pressed.connect(close)
	_rebuild_rows()


func _rebuild_rows() -> void:
	for child in slot_list.get_children():
		child.queue_free()
	for summary in SaveManager.list_slot_summaries():
		slot_list.add_child(_build_row(summary))


func _build_row(summary: Dictionary) -> Control:
	var row := PanelContainer.new()
	ArtCatalog.apply_parchment_panel(row)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var index: int = summary["index"]
	var name_label := Label.new()
	var turn_label := Label.new()
	if summary["occupied"]:
		var role_name := ""
		for role in LeaderRegistry.list_all():
			if role["id"] == summary.get("leader_id", ""):
				role_name = str(role["role"])
				break
		name_label.text = "Slot %d — %s" % [index + 1, str(summary.get("call_sign", "UNNAMED"))]
		turn_label.text = "%s · Turn %d" % [role_name, summary.get("turn", 0)]
	else:
		name_label.text = "Slot %d — Empty" % [index + 1]
		turn_label.text = "Start a new campaign here."
	ArtCatalog.style_ink_label(name_label, 16)
	ArtCatalog.style_ink_label(turn_label, 12, true)
	info.add_child(name_label)
	info.add_child(turn_label)

	if summary["occupied"]:
		var continue_btn := Button.new()
		continue_btn.text = "Continue"
		ArtCatalog.style_button(continue_btn)
		continue_btn.pressed.connect(_on_continue.bind(index))
		hbox.add_child(continue_btn)

		var delete_btn := Button.new()
		delete_btn.text = "Delete"
		ArtCatalog.style_button(delete_btn)
		delete_btn.pressed.connect(_on_delete.bind(index))
		hbox.add_child(delete_btn)
	else:
		var new_btn := Button.new()
		new_btn.text = "New Game"
		ArtCatalog.style_button(new_btn)
		new_btn.pressed.connect(_on_new_game.bind(index))
		hbox.add_child(new_btn)

	return row


func _on_continue(index: int) -> void:
	if not SaveManager.load_slot(index):
		return
	close()
	if GameSettings.onboarding_seen:
		SceneRouter.to_base_hub()
	else:
		SceneRouter.to_onboarding()


func _on_new_game(index: int) -> void:
	GameState.reset_campaign()
	SaveManager.active_slot = index
	close()
	if GameSettings.onboarding_seen:
		SceneRouter.to_character_select()
	else:
		SceneRouter.to_onboarding()


func _on_delete(index: int) -> void:
	SaveManager.delete_slot(index)
	_rebuild_rows()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		close()
		get_viewport().set_input_as_handled()


func close() -> void:
	if current == self:
		current = null
	closed.emit()
	queue_free()
