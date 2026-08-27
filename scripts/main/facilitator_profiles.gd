extends Control
## Facilitator Profiles — local-only "who's running this session" list.
## Display name + free-text notes. No clinical labels, no progress
## tracking; just session bookkeeping, matching the 2D reference build.

@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/VBox/Title
@onready var subtitle: Label = $Panel/Margin/VBox/Subtitle
@onready var name_field: LineEdit = $Panel/Margin/VBox/Form/NameRow/Name
@onready var notes_field: TextEdit = $Panel/Margin/VBox/Form/Notes
@onready var save_btn: Button = $Panel/Margin/VBox/Form/SaveRow/Save
@onready var list_box: VBoxContainer = $Panel/Margin/VBox/ScrollList/List
@onready var back_btn: Button = $Panel/Margin/VBox/Back


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 26)
	ArtCatalog.style_ink_label(subtitle, 14, true)
	ArtCatalog.style_button(save_btn)
	ArtCatalog.style_button(back_btn)

	save_btn.pressed.connect(_on_save_pressed)
	back_btn.pressed.connect(func(): SceneRouter.to_boot())
	name_field.text_changed.connect(func(_t): _refresh_save_enabled())

	_refresh_save_enabled()
	_refresh_list()


func _refresh_save_enabled() -> void:
	save_btn.disabled = name_field.text.strip_edges().length() == 0


func _on_save_pressed() -> void:
	var display_name := name_field.text.strip_edges()
	if display_name == "":
		return
	FacilitatorStore.save_profile(FacilitatorStore.new_id(), display_name, notes_field.text)
	name_field.text = ""
	notes_field.text = ""
	_refresh_save_enabled()
	_refresh_list()


func _refresh_list() -> void:
	for c in list_box.get_children():
		c.queue_free()
	var profiles := FacilitatorStore.list_profiles()
	if profiles.is_empty():
		var empty := Label.new()
		empty.text = "No facilitator profiles yet."
		ArtCatalog.style_ink_label(empty, 14, true)
		list_box.add_child(empty)
		return
	for profile in profiles:
		list_box.add_child(_build_row(profile))


func _build_row(profile: Dictionary) -> Control:
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
	name_label.text = str(profile.get("display_name", ""))
	ArtCatalog.style_ink_label(name_label, 18)
	text_col.add_child(name_label)

	var notes_label := Label.new()
	var notes_text := str(profile.get("notes", ""))
	notes_label.text = notes_text if notes_text != "" else "—"
	notes_label.autowrap_mode = 3 # AUTOWRAP_WORD_SMART
	ArtCatalog.style_ink_label(notes_label, 13, true)
	text_col.add_child(notes_label)

	var delete_btn := Button.new()
	delete_btn.text = "Delete"
	ArtCatalog.style_button(delete_btn)
	var profile_id := str(profile.get("id", ""))
	delete_btn.pressed.connect(func():
		FacilitatorStore.delete_profile(profile_id)
		_refresh_list())
	hbox.add_child(delete_btn)

	return row
