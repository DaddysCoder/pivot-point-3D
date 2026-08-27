class_name MissionEffects
extends RefCounted
## Applies Pivot choice effects to GameState.


static func apply(effects: Array) -> Dictionary:
	var result := {
		"complete": false,
		"route": "",
		"reopen_pivot": false,
		"resume": false,
	}
	for raw in effects:
		var e: Dictionary = raw
		match str(e.get("type", "")):
			"spend_materials":
				GameState.materials = maxi(0, GameState.materials - int(e.get("amount", 0)))
			"gain_materials":
				GameState.materials += int(e.get("amount", 0))
			"spend_intel":
				GameState.intel = maxi(0, GameState.intel - int(e.get("amount", 0)))
			"gain_intel":
				GameState.intel += int(e.get("amount", 0))
			"spend_influence":
				GameState.influence = maxi(0, GameState.influence - int(e.get("amount", 0)))
			"add_turns":
				GameState.turn += int(e.get("amount", 0))
			"flag":
				GameState.set_flag(str(e.get("key", "")), true)
			"unblock_crossing":
				GameState.set_flag("crossing_open", true)
			"complete_mission":
				result["complete"] = true
				result["route"] = str(e.get("route", "unknown"))
			"resume_mission":
				result["resume"] = true
			"reopen_pivot":
				result["reopen_pivot"] = true
			_:
				pass
	GameState.resources_changed.emit()
	return result


static func choice_affordable(choice: Dictionary) -> bool:
	for raw in choice.get("effects", []):
		var e: Dictionary = raw
		match str(e.get("type", "")):
			"spend_materials":
				if GameState.materials < int(e.get("amount", 0)):
					return false
			"spend_intel":
				if GameState.intel < int(e.get("amount", 0)):
					return false
			"spend_influence":
				if GameState.influence < int(e.get("amount", 0)):
					return false
	return true
