extends Node
## Named, multi-slot campaign saves keyed to the character built at creation.
## Local disk only (user://saves/) — no cloud, no accounts. Pairs with the
## slot picker overlay so Boot can offer "who's playing" instead of always
## starting or silently auto-resuming a single save.

const SAVE_DIR := "user://saves/"
const SLOT_COUNT := 3

## Which slot the current campaign is bound to, or -1 if none (fresh boot,
## not yet routed through the slot picker). Autosave hooks write here.
var active_slot: int = -1


func _slot_path(index: int) -> String:
	return SAVE_DIR + "slot_%d.json" % index


## Lightweight metadata for the slot picker: {index, occupied, call_sign,
## role, turn, updated_at} without loading the full save into GameState.
func slot_summary(index: int) -> Dictionary:
	var data := _read_slot(index)
	if data.is_empty():
		return {"index": index, "occupied": false}
	return {
		"index": index,
		"occupied": true,
		"call_sign": data.get("call_sign", ""),
		"leader_id": data.get("leader_id", ""),
		"turn": int(data.get("turn", 0)),
		"mission_status": int(data.get("mission_status", 0)),
		"updated_at": int(data.get("updated_at", 0)),
	}


func list_slot_summaries() -> Array:
	var out := []
	for i in SLOT_COUNT:
		out.append(slot_summary(i))
	return out


func has_any_save() -> bool:
	for i in SLOT_COUNT:
		if slot_summary(i)["occupied"]:
			return true
	return false


func _read_slot(index: int) -> Dictionary:
	var path := _slot_path(index)
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


## Serializes the current GameState into `index` and marks it as the
## active slot for future autosaves.
func save_to_slot(index: int) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var data := {
		"seed": GameState.seed,
		"leader_id": GameState.leader_id,
		"call_sign": GameState.call_sign,
		"pronouns": GameState.pronouns,
		"appearance": GameState.appearance,
		"materials": GameState.materials,
		"intel": GameState.intel,
		"influence": GameState.influence,
		"inventory": GameState.inventory,
		"active_loadout": GameState.active_loadout,
		"mission_id": GameState.mission_id,
		"mission_status": GameState.mission_status,
		"turn": GameState.turn,
		"pivot_count": GameState.pivot_count,
		"flags": GameState.flags,
		"director_enabled": GameState.director_enabled,
		"predictability": GameState.predictability,
		"director_intensity": GameState.director_intensity,
		"updated_at": int(Time.get_unix_time_from_system()),
	}
	var file := FileAccess.open(_slot_path(index), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	active_slot = index


## Autosaves to whichever slot the current campaign is bound to. No-op
## before a slot has been chosen (e.g. mid character creation on a fresh
## boot that hasn't gone through the slot picker).
func autosave() -> void:
	if active_slot >= 0:
		save_to_slot(active_slot)


## Restores GameState from `index`. Returns false (and leaves GameState
## untouched) if the slot is empty.
func load_slot(index: int) -> bool:
	var data := _read_slot(index)
	if data.is_empty():
		return false
	GameState.seed = int(data.get("seed", 42))
	GameState.leader_id = str(data.get("leader_id", ""))
	GameState.call_sign = str(data.get("call_sign", ""))
	GameState.pronouns = str(data.get("pronouns", ""))
	GameState.appearance = data.get("appearance", {"palette": "olive", "headwear": "none"})
	GameState.materials = int(data.get("materials", 8))
	GameState.intel = int(data.get("intel", 3))
	GameState.influence = int(data.get("influence", 1))
	GameState.inventory = data.get("inventory", [])
	GameState.active_loadout.assign(data.get("active_loadout", []))
	GameState.mission_id = str(data.get("mission_id", ""))
	GameState.mission_status = int(data.get("mission_status", GameState.MissionStatus.IDLE))
	GameState.turn = int(data.get("turn", 0))
	GameState.pivot_count = int(data.get("pivot_count", 0))
	GameState.flags = data.get("flags", {})
	GameState.director_enabled = bool(data.get("director_enabled", false))
	GameState.predictability = int(data.get("predictability", GameState.Predictability.BALANCED))
	GameState.director_intensity = int(data.get("director_intensity", 100))
	GameState.resources_changed.emit()
	GameState.inventory_changed.emit()
	GameState.loadout_changed.emit()
	active_slot = index
	return true


func delete_slot(index: int) -> void:
	var path := _slot_path(index)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if active_slot == index:
		active_slot = -1
