class_name SaveStore
extends RefCounted
## Named, multi-slot campaign saves, each tied to its own character —
## parity with the 2D reference build's SaveSlotsScreen (Dexie-backed
## there; plain JSON under user:// here, one file per slot).

const SAVE_DIR := "user://saves"


static func list_slots() -> Array:
	_ensure_dir()
	var out: Array = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return out
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var record := _read(file_name.trim_suffix(".json"))
			if not record.is_empty():
				out.append(record)
		file_name = dir.get_next()
	dir.list_dir_end()
	out.sort_custom(func(a, b): return float(a.get("updated_at", 0)) > float(b.get("updated_at", 0)))
	return out


## Saves the current GameState into slot `id`, creating or overwriting it.
static func save_slot(id: String, slot_name: String) -> void:
	_ensure_dir()
	var record := {
		"id": id,
		"slot_name": slot_name,
		"call_sign": GameState.call_sign,
		"role": GameState.leader_id,
		"updated_at": Time.get_unix_time_from_system(),
		"snapshot": GameState.to_snapshot(),
	}
	var f := FileAccess.open(_path_for(id), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(record))
	f.close()


## Loads slot `id` into GameState. Returns false if the slot is missing
## or unreadable (GameState is left untouched in that case).
static func load_slot(id: String) -> bool:
	var record := _read(id)
	var snapshot = record.get("snapshot", {})
	if typeof(snapshot) != TYPE_DICTIONARY:
		return false
	GameState.apply_snapshot(snapshot)
	GameState.active_slot_id = id
	GameState.active_slot_name = str(record.get("slot_name", ""))
	return true


static func delete_slot(id: String) -> void:
	var path := _path_for(id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


static func new_slot_id() -> String:
	return "save-%d-%04x" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec() % 0xFFFF]


static func _ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


static func _path_for(id: String) -> String:
	return "%s/%s.json" % [SAVE_DIR, id]


static func _read(id: String) -> Dictionary:
	var path := _path_for(id)
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
