class_name FacilitatorProfilesMenu
extends CanvasLayer
## Local-only facilitator profiles screen (Task 6). Display name + free-text
## notes per profile; nothing clinical, nothing synced off-device. Reachable
## from Boot for whoever is running the session to jot session notes.

signal closed

static var current: FacilitatorProfilesMenu = null

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/Outer/Title
@onready var subtitle: Label = $Panel/Margin/Outer/Subtitle
@onready var profile_list: VBoxContainer = $Panel/Margin/Outer/ProfileList
@onready var new_name: LineEdit = $Panel/Margin/Outer/NewRow/NewName
@onready var add_btn: Button = $Panel/Margin/Outer/NewRow/AddProfile
@onready var edit_panel: PanelContainer = $Panel/Margin/Outer/EditPanel
@onready var edit_name: LineEdit = $Panel/Margin/Outer/EditPanel/EditMargin/EditVBox/EditName
@onready var notes_label: Label = $Panel/Margin/Outer/EditPanel/EditMargin/EditVBox/NotesLabel
@onready var edit_notes: TextEdit = $Panel/Margin/Outer/EditPanel/EditMargin/EditVBox/EditNotes
@onready var save_edit_btn: Button = $Panel/Margin/Outer/EditPanel/EditMargin/EditVBox/EditButtons/SaveEdit
@onready var delete_edit_btn: Button = $Panel/Margin/Outer/EditPanel/EditMargin/EditVBox/EditButtons/DeleteEdit
@onready var close_btn: Button = $Panel/Margin/Outer/Close

var _editing_id: String = ""


static func open(parent: Node) -> FacilitatorProfilesMenu:
	if current:
		return current
	var scene := load("res://scenes/ui/facilitator_profiles_menu.tscn") as PackedScene
	var menu := scene.instantiate() as FacilitatorProfilesMenu
	current = menu
	parent.add_child(menu)
	return menu


func _ready() -> void:
	layer = 20
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.apply_parchment_panel(edit_panel)
	ArtCatalog.style_ink_label(title, 26)
	ArtCatalog.style_ink_label(subtitle, 13, true)
	ArtCatalog.style_ink_label(notes_label, 12, true)
	ArtCatalog.style_button(add_btn)
	ArtCatalog.style_button(save_edit_btn)
	ArtCatalog.style_button(delete_edit_btn)
	ArtCatalog.style_button(close_btn)

	add_btn.pressed.connect(_on_add_pressed)
	save_edit_btn.pressed.connect(_on_save_edit)
	delete_edit_btn.pressed.connect(_on_delete_edit)
	close_btn.pressed.connect(close)

	_rebuild_rows()


func _rebuild_rows() -> void:
	for child in profile_list.get_children():
		child.queue_free()
	for profile in FacilitatorProfiles.list_profiles():
		profile_list.add_child(_build_row(profile))


func _build_row(profile: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.text = str(profile.get("display_name", ""))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ArtCatalog.style_ink_label(name_label, 16)
	row.add_child(name_label)

	var edit_btn := Button.new()
	edit_btn.text = "Edit"
	ArtCatalog.style_button(edit_btn)
	edit_btn.pressed.connect(_on_edit_pressed.bind(str(profile.get("id", ""))))
	row.add_child(edit_btn)

	return row


func _on_add_pressed() -> void:
	var trimmed := new_name.text.strip_edges()
	if trimmed == "":
		return
	FacilitatorProfiles.create_profile(trimmed)
	new_name.text = ""
	_rebuild_rows()


func _on_edit_pressed(id: String) -> void:
	var profile := FacilitatorProfiles.get_profile(id)
	if profile.is_empty():
		return
	_editing_id = id
	edit_name.text = str(profile.get("display_name", ""))
	edit_notes.text = str(profile.get("notes", ""))
	edit_panel.visible = true


func _on_save_edit() -> void:
	if _editing_id == "":
		return
	FacilitatorProfiles.update_profile(_editing_id, edit_name.text, edit_notes.text)
	edit_panel.visible = false
	_editing_id = ""
	_rebuild_rows()


func _on_delete_edit() -> void:
	if _editing_id == "":
		return
	FacilitatorProfiles.delete_profile(_editing_id)
	edit_panel.visible = false
	_editing_id = ""
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
