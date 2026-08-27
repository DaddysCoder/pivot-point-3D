extends CanvasLayer
## Parchment Pivot Event card — concept art + choices.


signal choice_selected(choice_id: String)

@onready var panel: PanelContainer = $Root/Panel
@onready var art: TextureRect = $Root/Panel/Margin/VBox/EventArt
@onready var title: Label = $Root/Panel/Margin/VBox/Title
@onready var status: Label = $Root/Panel/Margin/VBox/Status
@onready var flavor: Label = $Root/Panel/Margin/VBox/Flavor
@onready var choices_box: VBoxContainer = $Root/Panel/Margin/VBox/Choices
@onready var header: Label = $Root/Panel/Margin/VBox/Header


func _ready() -> void:
	visible = false
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(header, 14, true)
	ArtCatalog.style_ink_label(title, 28)
	ArtCatalog.style_ink_label(status, 16)
	ArtCatalog.style_ink_label(flavor, 14, true)
	GameState.pivot_opened.connect(_on_pivot_opened)
	GameState.pivot_closed.connect(_on_pivot_closed)


func _on_pivot_opened(event_id: String) -> void:
	var ev := PivotLibrary.get_event(event_id)
	if ev.is_empty():
		return
	title.text = str(ev.get("title", event_id))
	status.text = str(ev.get("status", ""))
	flavor.text = str(ev.get("flavor", ""))
	var tex := ArtCatalog.event_art(event_id)
	if tex:
		art.texture = tex
		art.visible = true
	else:
		art.visible = false
	_rebuild_choices()
	visible = true
	GameState.input_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_pivot_closed() -> void:
	visible = false
	GameState.input_locked = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _rebuild_choices() -> void:
	for c in choices_box.get_children():
		c.queue_free()
	for choice in SupplyLineMission.get_visible_choices():
		var btn := Button.new()
		var label := str(choice.get("label", choice.get("id", "")))
		var req: Array = choice.get("require_equipment", [])
		if not req.is_empty():
			label += "  [%s]" % ", ".join(PackedStringArray(req))
		btn.text = label
		btn.tooltip_text = str(choice.get("description", ""))
		btn.disabled = not bool(choice.get("affordable", true))
		ArtCatalog.style_button(btn)
		var cid := str(choice["id"])
		btn.pressed.connect(func(): _select(cid))
		choices_box.add_child(btn)


func _select(choice_id: String) -> void:
	choice_selected.emit(choice_id)
	var result := SupplyLineMission.resolve_choice(choice_id)
	if result.get("reopen", false):
		_rebuild_choices()
		return
	if result.get("complete", false):
		visible = false
		SceneRouter.to_after_action()
