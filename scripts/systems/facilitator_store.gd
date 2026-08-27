class_name FacilitatorStore
extends RefCounted
## Local-only "who's running this session" profiles: display name + free
## text notes. No clinical labels or structured diagnosis fields — mirrors
## the 2D reference build's Mission Control profiles, minus its
## preferredPredictability field (that belongs to Play Style, not identity).
##
## Persisted as plain JSON under user:// — independent of the campaign
## save-slot system (a separate concern), so this works without it.

const SAVE_PATH := "user://facilitator_profiles.json"


static func list_profiles() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return []
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		return []
	return parsed as Array


static func save_profile(id: String, display_name: String, notes: String) -> Dictionary:
	var profiles := list_profiles()
	var profile := {}
	for p in profiles:
		if p.get("id", "") == id:
			profile = p
			break
	if profile.is_empty():
		profile = {"id": id, "created_at": Time.get_unix_time_from_system()}
		profiles.append(profile)
	profile["display_name"] = display_name
	profile["notes"] = notes
	_write(profiles)
	return profile


static func delete_profile(id: String) -> void:
	var profiles := list_profiles()
	profiles = profiles.filter(func(p): return p.get("id", "") != id)
	_write(profiles)


static func new_id() -> String:
	return "fac-%06x" % (Time.get_ticks_usec() % 0xFFFFFF)


static func _write(profiles: Array) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(profiles))
	f.close()
