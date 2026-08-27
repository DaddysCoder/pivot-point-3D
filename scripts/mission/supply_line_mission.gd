class_name SupplyLineMission
extends RefCounted
## Supply Line — Kingsroad to Highwatch via the destroyed bridge.


const MISSION_ID := "supply-line"


static func begin() -> void:
	GameState.clear_mission()
	GameState.mission_id = MISSION_ID
	GameState.mission_status = GameState.MissionStatus.ACTIVE
	GameState.turn = 1
	GameState.available_choice_ids = ["approach-kingsroad"]
	GameState.append_log("Supply Line opened. Kingsroad toward Highwatch.")
	GameState.mission_changed.emit()


static func on_arrive_crossing() -> void:
	if GameState.active_event_id != "":
		return
	if "bridge-destroyed" in GameState.triggered_event_ids:
		return
	open_pivot("bridge-destroyed")


static func open_pivot(event_id: String) -> void:
	var ev := PivotLibrary.get_event(event_id)
	if ev.is_empty():
		return
	GameState.resume_choice_ids = GameState.available_choice_ids.duplicate()
	GameState.active_event_id = event_id
	GameState.mission_status = GameState.MissionStatus.PIVOT
	GameState.pivot_count += 1
	if event_id not in GameState.triggered_event_ids:
		GameState.triggered_event_ids.append(event_id)
	GameState.available_choice_ids = _filter_choices(ev)
	GameState.append_log("PIVOT — %s" % ev.get("title", event_id))
	GameState.pivot_opened.emit(event_id)
	GameState.mission_changed.emit()


static func _filter_choices(ev: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for c in ev.get("choices", []):
		var req: Array = c.get("require_equipment", [])
		if not GameState.loadout_has_all(req):
			continue
		ids.append(str(c["id"]))
	return ids


static func get_visible_choices() -> Array:
	var ev := PivotLibrary.get_event(GameState.active_event_id)
	if ev.is_empty():
		return []
	var out: Array = []
	for c in ev.get("choices", []):
		if str(c["id"]) in GameState.available_choice_ids:
			var copy: Dictionary = c.duplicate(true)
			copy["affordable"] = MissionEffects.choice_affordable(c)
			out.append(copy)
	return out


static func resolve_choice(choice_id: String) -> Dictionary:
	var ev := PivotLibrary.get_event(GameState.active_event_id)
	if ev.is_empty():
		return {"ok": false, "reason": "no_event"}
	var choice := {}
	for c in ev.get("choices", []):
		if c["id"] == choice_id:
			choice = c
			break
	if choice.is_empty():
		return {"ok": false, "reason": "unknown_choice"}
	if choice_id not in GameState.available_choice_ids:
		return {"ok": false, "reason": "not_available"}
	if not MissionEffects.choice_affordable(choice):
		return {"ok": false, "reason": "cannot_afford"}

	CraftingEngine.consume_list(choice.get("consume_equipment", []))
	var applied := MissionEffects.apply(choice.get("effects", []))
	GameState.remember_action(str(choice.get("action_type", "adapt")))
	GameState.append_log("Chose: %s" % choice.get("label", choice_id))
	GameState.tick_director_after_decision()

	if applied.get("reopen_pivot", false):
		GameState.available_choice_ids = _filter_choices(ev)
		GameState.mission_changed.emit()
		return {"ok": true, "reopen": true}

	_close_pivot()

	if applied.get("complete", false):
		_complete(str(applied.get("route", "unknown")))
		return {"ok": true, "complete": true}

	# Resume and maybe Director
	GameState.mission_status = GameState.MissionStatus.ACTIVE
	GameState.available_choice_ids = GameState.resume_choice_ids.duplicate()
	if GameState.available_choice_ids.is_empty():
		GameState.available_choice_ids = ["continue-to-highwatch"]
	GameState.mission_changed.emit()

	var director_result := AdaptiveDirector.evaluate_and_maybe_trigger()
	return {"ok": true, "director": director_result}


static func _close_pivot() -> void:
	GameState.active_event_id = ""
	GameState.pivot_closed.emit()


static func _complete(route: String) -> void:
	GameState.final_route = route
	GameState.mission_status = GameState.MissionStatus.COMPLETE
	GameState.active_event_id = ""
	GameState.append_log("Mission complete via %s." % route)
	var summary := {
		"mission_id": MISSION_ID,
		"route": route,
		"turns": GameState.turn,
		"pivots": GameState.pivot_count,
		"flags": GameState.flags.duplicate(),
		"log": GameState.mission_log.duplicate(),
		"leader": GameState.leader_id,
		"materials": GameState.materials,
		"intel": GameState.intel,
	}
	GameState.last_after_action = summary
	GameState.after_action_ready.emit(summary)
	GameState.mission_changed.emit()


static func finish_with_route(route: String) -> void:
	GameState.turn += 1
	GameState.append_log("Column reaches Highwatch Hold.")
	_complete(route)


static func continue_to_highwatch() -> void:
	finish_with_route("direct")
