extends Control
## COMMISSION AN OPERATOR — call sign, pronouns, role, palette, headwear,
## with a live field preview. Role keeps LeaderRegistry's mechanical bonus;
## everything else is player-authored, not a fixed preset identity.

@onready var bg: TextureRect = $BgArt
@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/HBox/FormScroll/Form/Title
@onready var call_sign_label: Label = $Panel/Margin/HBox/FormScroll/Form/CallSignRow/Label
@onready var call_sign_field: LineEdit = $Panel/Margin/HBox/FormScroll/Form/CallSignRow/CallSign
@onready var pronouns_label: Label = $Panel/Margin/HBox/FormScroll/Form/PronounsRow/Label
@onready var pronouns_field: LineEdit = $Panel/Margin/HBox/FormScroll/Form/PronounsRow/Pronouns
@onready var role_label: Label = $Panel/Margin/HBox/FormScroll/Form/RoleLabel
@onready var role_grid: GridContainer = $Panel/Margin/HBox/FormScroll/Form/RoleGrid
@onready var role_detail: Label = $Panel/Margin/HBox/FormScroll/Form/RoleDetail
@onready var palette_label: Label = $Panel/Margin/HBox/FormScroll/Form/PaletteLabel
@onready var palette_row: HBoxContainer = $Panel/Margin/HBox/FormScroll/Form/PaletteRow
@onready var headwear_label: Label = $Panel/Margin/HBox/FormScroll/Form/HeadwearLabel
@onready var headwear_row: HBoxContainer = $Panel/Margin/HBox/FormScroll/Form/HeadwearRow
@onready var confirm: Button = $Panel/Margin/HBox/FormScroll/Form/Confirm
@onready var preview: PanelContainer = $Panel/Margin/HBox/Preview
@onready var preview_label: Label = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/PreviewLabel
@onready var preview_headwear: HeadwearPreview = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/HeadwearHolder/PreviewHeadwear
@onready var preview_call_sign: Label = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/PreviewCallSign
@onready var preview_role: Label = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/PreviewRole
@onready var preview_pronouns: Label = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/PreviewPronouns
@onready var preview_bonus: Label = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/PreviewBonus
@onready var preview_portrait: TextureRect = $Panel/Margin/HBox/Preview/PreviewMargin/PreviewVBox/PreviewPortrait

var _selected_role: String = ""
var _selected_palette: String = "olive"
var _selected_headwear: String = "none"
var _role_buttons: Dictionary = {}
var _palette_buttons: Dictionary = {}
var _headwear_buttons: Dictionary = {}


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tex := ArtCatalog.texture(ArtCatalog.CHAR_SELECT)
	if tex:
		bg.texture = tex
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 26)
	for label in [call_sign_label, pronouns_label, role_label, palette_label, headwear_label]:
		ArtCatalog.style_ink_label(label, 16, true)
	ArtCatalog.style_ink_label(role_detail, 14, true)
	ArtCatalog.style_ink_label(preview_label, 12, true)
	ArtCatalog.style_ink_label(preview_call_sign, 22)
	ArtCatalog.style_ink_label(preview_role, 14, true)
	ArtCatalog.style_ink_label(preview_pronouns, 14, true)
	ArtCatalog.style_ink_label(preview_bonus, 14, true)
	ArtCatalog.apply_parchment_panel(preview)
	ArtCatalog.style_button(confirm)

	_build_role_grid()
	_build_palette_row()
	_build_headwear_row()

	call_sign_field.text_changed.connect(_on_call_sign_changed)
	pronouns_field.text_changed.connect(_on_pronouns_changed)
	confirm.pressed.connect(_confirm)

	_select_headwear(_selected_headwear)
	_refresh_preview()
	call_sign_field.grab_focus()


func _build_role_grid() -> void:
	for role in LeaderRegistry.list_all():
		var btn := Button.new()
		var rid := str(role["id"])
		btn.text = "%s\n%s" % [role["role"], role["bonus"]]
		btn.custom_minimum_size = Vector2(180, 84)
		btn.focus_mode = Control.FOCUS_ALL
		btn.toggle_mode = true
		ArtCatalog.style_button(btn)
		btn.pressed.connect(func(): _select_role(rid))
		role_grid.add_child(btn)
		_role_buttons[rid] = btn


func _build_palette_row() -> void:
	for palette_id in CharacterOptions.PALETTE_ORDER:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.focus_mode = Control.FOCUS_ALL
		btn.tooltip_text = palette_id.capitalize()
		ArtCatalog.style_button(btn)
		var color := CharacterOptions.palette_color(palette_id)
		var normal := StyleBoxFlat.new()
		normal.bg_color = color
		normal.border_color = ArtCatalog.WOOD
		normal.set_border_width_all(2)
		var selected := normal.duplicate() as StyleBoxFlat
		selected.border_color = ArtCatalog.GOLD
		selected.set_border_width_all(4)
		btn.set_meta("normal_style", normal)
		btn.set_meta("selected_style", selected)
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", normal)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.pressed.connect(func(): _select_palette(palette_id))
		palette_row.add_child(btn)
		_palette_buttons[palette_id] = btn


func _build_headwear_row() -> void:
	for headwear_id in CharacterOptions.HEADWEAR:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(64, 64)
		btn.focus_mode = Control.FOCUS_ALL
		btn.toggle_mode = true
		btn.tooltip_text = headwear_id.capitalize()
		ArtCatalog.style_button(btn)
		var icon := HeadwearPreview.new()
		icon.custom_minimum_size = Vector2(48, 40)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_anchors_preset(Control.PRESET_CENTER)
		icon.set_state(headwear_id, CharacterOptions.palette_color(_selected_palette))
		btn.add_child(icon)
		btn.pressed.connect(func(): _select_headwear(headwear_id))
		headwear_row.add_child(btn)
		_headwear_buttons[headwear_id] = {"btn": btn, "icon": icon}


func _select_role(role_id: String) -> void:
	_selected_role = role_id
	for id in _role_buttons:
		(_role_buttons[id] as Button).button_pressed = (id == role_id)
	for role in LeaderRegistry.list_all():
		if role["id"] == role_id:
			role_detail.text = "%s — %s" % [role["role"], role["blurb"]]
			break
	_refresh_preview()
	_refresh_confirm()


func _select_palette(palette_id: String) -> void:
	_selected_palette = palette_id
	for id in _palette_buttons:
		var btn: Button = _palette_buttons[id]
		var style: StyleBoxFlat = btn.get_meta("selected_style" if id == palette_id else "normal_style")
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
	var color := CharacterOptions.palette_color(palette_id)
	for id in _headwear_buttons:
		(_headwear_buttons[id]["icon"] as HeadwearPreview).set_state(str(id), color)
	_refresh_preview()


func _select_headwear(headwear_id: String) -> void:
	_selected_headwear = headwear_id
	for id in _headwear_buttons:
		(_headwear_buttons[id]["btn"] as Button).button_pressed = (id == headwear_id)
	_refresh_preview()


func _on_call_sign_changed(_text: String) -> void:
	_refresh_preview()
	_refresh_confirm()


func _on_pronouns_changed(_text: String) -> void:
	_refresh_preview()


func _refresh_preview() -> void:
	var color := CharacterOptions.palette_color(_selected_palette)
	preview_headwear.set_state(_selected_headwear, color)
	preview_call_sign.text = call_sign_field.text.strip_edges().to_upper() if call_sign_field.text.strip_edges() != "" else "——"
	preview_pronouns.text = pronouns_field.text.strip_edges()
	if _selected_role == "":
		preview_role.text = "No role selected"
		preview_bonus.text = ""
		preview_portrait.visible = false
	else:
		for role in LeaderRegistry.list_all():
			if role["id"] == _selected_role:
				preview_role.text = str(role["role"])
				preview_bonus.text = str(role["bonus"])
				break
		var portrait := ArtCatalog.leader_portrait(_selected_role)
		preview_portrait.texture = portrait
		preview_portrait.visible = portrait != null


func _refresh_confirm() -> void:
	confirm.disabled = not (call_sign_field.text.strip_edges().length() >= 2 and _selected_role != "")


func _confirm() -> void:
	if confirm.disabled:
		return
	var appearance := {"palette": _selected_palette, "headwear": _selected_headwear}
	GameState.set_character(
		_selected_role,
		call_sign_field.text.strip_edges().to_upper(),
		pronouns_field.text.strip_edges(),
		appearance,
	)
	LeaderRegistry.apply_starting_bonus(_selected_role)
	SaveManager.autosave()
	SceneRouter.to_base_hub()
