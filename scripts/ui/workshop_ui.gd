extends CanvasLayer
## Workshop + loadout for Base Hub.


@onready var panel: PanelContainer = $Root/Panel
@onready var resources_label: Label = $Root/Panel/Margin/VBox/Resources
@onready var list: VBoxContainer = $Root/Panel/Margin/VBox/BlueprintList
@onready var loadout_label: Label = $Root/Panel/Margin/VBox/Loadout
@onready var close_btn: Button = $Root/Panel/Margin/VBox/Close
@onready var title: Label = $Root/Panel/Margin/VBox/Title
@onready var hint: Label = $Root/Panel/Margin/VBox/Hint


func _ready() -> void:
	visible = false
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 24)
	ArtCatalog.style_ink_label(resources_label, 16)
	ArtCatalog.style_ink_label(loadout_label, 15)
	ArtCatalog.style_ink_label(hint, 13, true)
	ArtCatalog.style_button(close_btn)
	close_btn.pressed.connect(close)
	GameState.resources_changed.connect(_refresh)
	GameState.inventory_changed.connect(_refresh)
	GameState.loadout_changed.connect(_refresh)


func open() -> void:
	_refresh()
	visible = true
	GameState.input_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close() -> void:
	visible = false
	GameState.input_locked = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _refresh() -> void:
	resources_label.text = "Materials: %d   Intel: %d   Influence: %d" % [
		GameState.materials, GameState.intel, GameState.influence
	]
	var load_names: PackedStringArray = PackedStringArray()
	for id in GameState.active_loadout:
		var d := CraftingEngine.get_definition(id)
		load_names.append(str(d.get("name", id)))
	loadout_label.text = "Loadout (%d/%d): %s" % [
		GameState.active_loadout.size(), CraftingEngine.LOADOUT_LIMIT,
		(", ".join(load_names) if load_names.size() > 0 else "empty"),
	]
	for c in list.get_children():
		c.queue_free()
	for b in CraftingEngine.list_blueprints():
		var row := HBoxContainer.new()
		var info := Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var owned := GameState.get_owned_quantity(str(b["id"]))
		var intel_bit := ""
		if int(b.get("intel_cost", 0)) > 0:
			intel_bit = " + %d intel" % int(b["intel_cost"])
		info.text = "%s — %d mat%s  (owned %d)" % [b["name"], b["material_cost"], intel_bit, owned]
		info.tooltip_text = str(b.get("purpose", b.get("description", "")))
		ArtCatalog.style_ink_label(info, 14)
		row.add_child(info)
		var craft_btn := Button.new()
		craft_btn.text = "Craft"
		craft_btn.disabled = not CraftingEngine.can_craft(str(b["id"]))["ok"]
		var eid := str(b["id"])
		craft_btn.pressed.connect(func(): CraftingEngine.craft(eid); _refresh())
		ArtCatalog.style_button(craft_btn)
		row.add_child(craft_btn)
		var eq_btn := Button.new()
		eq_btn.text = "Equip"
		eq_btn.disabled = owned <= 0 or eid in GameState.active_loadout or GameState.active_loadout.size() >= CraftingEngine.LOADOUT_LIMIT
		eq_btn.pressed.connect(func(): CraftingEngine.equip(eid); _refresh())
		ArtCatalog.style_button(eq_btn)
		row.add_child(eq_btn)
		var uq_btn := Button.new()
		uq_btn.text = "Unequip"
		uq_btn.disabled = eid not in GameState.active_loadout
		uq_btn.pressed.connect(func(): CraftingEngine.unequip(eid); _refresh())
		ArtCatalog.style_button(uq_btn)
		row.add_child(uq_btn)
		list.add_child(row)
