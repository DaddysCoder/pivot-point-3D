extends CanvasLayer
## Lightweight mission HUD.


@onready var resources: Label = $Root/Resources
@onready var mission: Label = $Root/Mission
@onready var advisory: Label = $Root/Advisory
@onready var loadout: Label = $Root/Loadout


func _ready() -> void:
	GameState.resources_changed.connect(_refresh)
	GameState.loadout_changed.connect(_refresh)
	GameState.mission_changed.connect(_refresh)
	GameState.advisory_changed.connect(_on_advisory)
	_refresh()


func _on_advisory(text: String) -> void:
	advisory.text = text


func _refresh() -> void:
	resources.text = "Mat %d · Intel %d · Inf %d" % [GameState.materials, GameState.intel, GameState.influence]
	var status := ""
	match GameState.mission_status:
		GameState.MissionStatus.IDLE:
			status = "Hub"
		GameState.MissionStatus.ACTIVE:
			status = "Supply Line · turn %d" % GameState.turn
		GameState.MissionStatus.PIVOT:
			status = "PIVOT · %s" % GameState.active_event_id
		GameState.MissionStatus.COMPLETE:
			status = "Complete"
		_:
			status = str(GameState.mission_status)
	mission.text = status
	var names: PackedStringArray = PackedStringArray()
	for id in GameState.active_loadout:
		names.append(str(CraftingEngine.get_definition(id).get("name", id)))
	loadout.text = "Loadout: " + (", ".join(names) if names.size() else "—")
	if GameState.advisory_text != "":
		advisory.text = GameState.advisory_text
	elif advisory.text.begins_with("FIELD"):
		pass
	else:
		advisory.text = ""
