extends Node
## Local-only facilitator profiles: a display name and free-text notes.
## No clinical fields, no diagnosis picklists, nothing synced off-device —
## this is a name tag and a notebook, not a clinical record. Matches the
## 2D reference build's "no clinical labels in player view" boundary.

const SAVE_PATH := "user://facilitator_profiles.json"

## Which profile is active this session, or "" if none selected.
var active_id: String = ""

var _profiles: Array = [] ## [{id, display_name, notes}, ...]

var _loaded: bool = false


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	if FileAccess.file_exists(SAVE_PATH):
		var text := FileAccess.get_file_as_string(SAVE_PATH)
		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_ARRAY:
			_profiles = parsed


func _persist() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_profiles))
		file.close()


func list_profiles() -> Array:
	_ensure_loaded()
	return _profiles.duplicate(true)


func get_profile(id: String) -> Dictionary:
	_ensure_loaded()
	for p in _profiles:
		if p.get("id", "") == id:
			return p
	return {}


## Creates a profile with `display_name` and empty notes. Returns its id.
func create_profile(display_name: String) -> String:
	_ensure_loaded()
	var id := "facilitator-%d" % Time.get_ticks_usec()
	_profiles.append({"id": id, "display_name": display_name.strip_edges(), "notes": ""})
	_persist()
	return id


func update_profile(id: String, display_name: String, notes: String) -> void:
	_ensure_loaded()
	for p in _profiles:
		if p.get("id", "") == id:
			p["display_name"] = display_name.strip_edges()
			p["notes"] = notes
			_persist()
			return


func delete_profile(id: String) -> void:
	_ensure_loaded()
	_profiles = _profiles.filter(func(p): return p.get("id", "") != id)
	if active_id == id:
		active_id = ""
	_persist()
