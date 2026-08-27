extends Node
## Persistent campaign / mission state for Pivot Point 3D.
## Pure data + helpers. Systems mutate through this autoload.

signal resources_changed
signal inventory_changed
signal loadout_changed
signal mission_changed
signal pivot_opened(event_id: String)
signal pivot_closed
signal advisory_changed(text: String)
signal log_appended(line: String)
signal after_action_ready(summary: Dictionary)

const LOADOUT_LIMIT := 2

enum Predictability { HIGH, BALANCED, UNPREDICTABLE }
enum MissionStatus { IDLE, BRIEFING, ACTIVE, PIVOT, COMPLETE, FAILED }

var seed: int = 42
var leader_id: String = ""
var call_sign: String = ""
var pronouns: String = ""
var appearance: Dictionary = {"palette": "olive", "headwear": "none"}
var materials: int = 8
var intel: int = 3
var influence: int = 1

var inventory: Array = [] ## [{id: String, quantity: int}, ...]
var active_loadout: Array[String] = []

var mission_id: String = ""
var mission_status: MissionStatus = MissionStatus.IDLE
var turn: int = 0
var pivot_count: int = 0
var active_event_id: String = ""
var triggered_event_ids: Array[String] = []
var flags: Dictionary = {}
var mission_log: Array[String] = []
var available_choice_ids: Array[String] = []
var resume_choice_ids: Array[String] = []
var final_route: String = ""
var advisory_text: String = ""

## Director runtime
var director_enabled: bool = false
var predictability: Predictability = Predictability.BALANCED
var director_intensity: int = 100
var director_cooldown: int = 0
var director_history: Array = [] ## [{event_id, category, turn}, ...]
var director_recent_actions: Array[String] = []
var director_advisory_pending: String = ""
var director_last_decision: String = "none"

var last_after_action: Dictionary = {}
var input_locked: bool = false


func reset_campaign(new_seed: int = -1) -> void:
	if new_seed < 0:
		seed = int(Time.get_unix_time_from_system()) & 0x7fffffff
	else:
		seed = new_seed
	leader_id = ""
	call_sign = ""
	pronouns = ""
	appearance = {"palette": "olive", "headwear": "none"}
	materials = 8
	intel = 3
	influence = 1
	inventory.clear()
	active_loadout.clear()
	clear_mission()
	director_intensity = 100
	director_cooldown = 0
	director_history.clear()
	director_recent_actions.clear()
	director_advisory_pending = ""
	director_last_decision = "none"
	advisory_text = ""
	last_after_action = {}
	input_locked = false
	resources_changed.emit()
	inventory_changed.emit()
	loadout_changed.emit()


func clear_mission() -> void:
	mission_id = ""
	mission_status = MissionStatus.IDLE
	turn = 0
	pivot_count = 0
	active_event_id = ""
	triggered_event_ids.clear()
	flags.clear()
	mission_log.clear()
	available_choice_ids.clear()
	resume_choice_ids.clear()
	final_route = ""
	mission_changed.emit()


func set_leader(id: String) -> void:
	leader_id = id


## Persists the operator built in the character creator: role, call sign,
## optional pronouns, and cosmetic appearance (palette + headwear).
func set_character(role_id: String, new_call_sign: String, new_pronouns: String, new_appearance: Dictionary) -> void:
	leader_id = role_id
	call_sign = new_call_sign
	pronouns = new_pronouns
	appearance = new_appearance.duplicate()


func append_log(line: String) -> void:
	mission_log.append(line)
	log_appended.emit(line)


func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value


func has_flag(key: String) -> bool:
	return bool(flags.get(key, false))


func get_owned_quantity(equipment_id: String) -> int:
	for e in inventory:
		if e.get("id", "") == equipment_id:
			return int(e.get("quantity", 0))
	return 0


func loadout_has(equipment_id: String) -> bool:
	return equipment_id in active_loadout


func loadout_has_all(required: Array) -> bool:
	if required.is_empty():
		return true
	for id in required:
		if not loadout_has(str(id)):
			return false
	return true


func remember_action(action_type: String) -> void:
	director_recent_actions.append(action_type)
	while director_recent_actions.size() > 5:
		director_recent_actions.remove_at(0)


func tick_director_after_decision() -> void:
	if director_cooldown > 0:
		director_cooldown -= 1
