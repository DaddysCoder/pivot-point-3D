extends Control
## "Who's playing" — named save-slot picker in front of Continue, instead
## of silently auto-resuming the last save (a gap the 2D reference build
## itself still has). Each slot is tied to its own character.

@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/VBox/Title
@onready var subtitle: Label = $Panel/Margin/VBox/Subtitle
@onready var scroll_list: ScrollContainer = $Panel/Margin/VBox/ScrollList
@onready var list_box: VBoxContainer = $Panel/Margin/VBox/ScrollList/List
@onready var new_campaign_btn: Button = $Panel/Margin/VBox/Actions/NewCampaign
@onready var back_btn: Button = $Panel/Margin/VBox/Actions/Back


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 26)
	ArtCatalog.style_ink_label(subtitle, 14, true)
	ArtCatalog.style_button(new_campaign_btn)
	ArtCatalog.style_button(back_btn)

	new_campaign_btn.pressed.connect(_on_new_campaign_pressed)
	back_btn.pressed.connect(func(): SceneRouter.to_boot())

	_refresh_list()


func _on_new_campaign_pressed() -> void:
	GameState.reset_campaign()
	if GameSettings.onboarding_seen:
		SceneRouter.to_character_select()
	else:
		SceneRouter.to_onboarding()


func _refresh_list() -> void:
	for c in list_box.get_children():
		c.queue_free()
	var slots := SaveStore.list_slots()
	if slots.is_empty():
		var empty := Label.new()
		empty.text = "No saved campaigns yet. Start a new one below."
		ArtCatalog.style_ink_label(empty, 14, true)
		list_box.add_child(empty)
		return
	for slot in slots:
		list_box.add_child(_build_row(slot))


func _build_row(slot: Dictionary) -> Control:
	var row := PanelContainer.new()
	ArtCatalog.apply_parchment_panel(row)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	row.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_col)

	var name_label := Label.new()
	name_label.text = str(slot.get("slot_name", slot.get("call_sign", "UNNAMED")))
	ArtCatalog.style_ink_label(name_label, 18)
	text_col.add_child(name_label)

	var detail_label := Label.new()
	detail_label.text = _describe(slot)
	ArtCatalog.style_ink_label(detail_label, 13, true)
	text_col.add_child(detail_label)

	var load_btn := Button.new()
	load_btn.text = "Load"
	ArtCatalog.style_button(load_btn)
	var slot_id := str(slot.get("id", ""))
	load_btn.pressed.connect(func(): _load(slot_id))
	hbox.add_child(load_btn)

	var delete_btn := Button.new()
	delete_btn.text = "Delete"
	ArtCatalog.style_button(delete_btn)
	delete_btn.pressed.connect(func():
		SaveStore.delete_slot(slot_id)
		_refresh_list())
	hbox.add_child(delete_btn)

	return row


func _describe(slot: Dictionary) -> String:
	var role := str(slot.get("role", ""))
	var snapshot: Dictionary = slot.get("snapshot", {})
	var status_names := ["Hub", "Briefing", "Supply Line", "Pivot", "Complete", "Failed"]
	var status_index := int(snapshot.get("mission_status", 0))
	var status := status_names[status_index] if status_index >= 0 and status_index < status_names.size() else "Unknown"
	return "%s · %s" % [role.capitalize(), status]


func _load(slot_id: String) -> void:
	if not SaveStore.load_slot(slot_id):
		return
	match GameState.mission_status:
		GameState.MissionStatus.ACTIVE, GameState.MissionStatus.PIVOT, GameState.MissionStatus.BRIEFING:
			SceneRouter.to_supply_line()
		_:
			SceneRouter.to_base_hub()
