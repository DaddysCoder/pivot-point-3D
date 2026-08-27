extends Node
## Autosaves the active named save slot whenever campaign state changes.
## No-ops until a slot exists (set by the character creator or by loading
## an existing save from the slot picker).


func _ready() -> void:
	GameState.resources_changed.connect(_autosave)
	GameState.inventory_changed.connect(_autosave)
	GameState.loadout_changed.connect(_autosave)
	GameState.mission_changed.connect(_autosave)
	GameState.after_action_ready.connect(func(_summary): _autosave())


func _autosave() -> void:
	if GameState.active_slot_id == "":
		return
	SaveStore.save_slot(GameState.active_slot_id, GameState.active_slot_name)
