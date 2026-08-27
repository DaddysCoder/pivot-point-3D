class_name AdaptiveDirector
extends RefCounted
## Local deterministic Director. Selects pre-authored events only. No LLM/API.


const COOLDOWN_AFTER_TRIGGER := 2
const INTENSITY_COST := 25
const INTENSITY_MAX := 100

## Director-injected events (bridge is mission-scripted on arrive).
static var CANDIDATES: Array = [
	{"event_id": "supplies-delayed", "category": "resource", "min_turn": 1, "intensity": 20, "affinity_tags": ["supply"]},
	{"event_id": "scout-missing", "category": "recon", "min_turn": 1, "intensity": 25, "affinity_tags": ["recon"]},
	{"event_id": "weather-changes", "category": "weather", "min_turn": 1, "intensity": 15, "affinity_tags": []},
	{"event_id": "new-information", "category": "intel", "min_turn": 1, "intensity": 20, "affinity_tags": ["recon"]},
	{"event_id": "ally-offers-help", "category": "ally", "min_turn": 2, "intensity": 20, "affinity_tags": ["ask", "comms"]},
]


static func evaluate_and_maybe_trigger() -> Dictionary:
	var decision := evaluate()
	GameState.director_last_decision = str(decision.get("type", "none"))
	match decision.get("type", "none"):
		"advisory":
			var title := str(PivotLibrary.get_event(decision["event_id"]).get("title", decision["event_id"]))
			GameState.director_advisory_pending = str(decision["event_id"])
			GameState.advisory_text = "FIELD ADVISORY — Possible complication: %s" % title
			GameState.advisory_changed.emit(GameState.advisory_text)
			return decision
		"trigger":
			_apply_trigger(str(decision["event_id"]), decision.get("reason_codes", []))
			return decision
		_:
			GameState.advisory_text = ""
			return decision


static func evaluate() -> Dictionary:
	if not GameState.director_enabled:
		return {"type": "none", "reason_codes": ["director_disabled"]}
	if GameState.mission_id != SupplyLineMission.MISSION_ID:
		return {"type": "none", "reason_codes": ["mission_not_allowlisted"]}
	if GameState.mission_status != GameState.MissionStatus.ACTIVE:
		return {"type": "none", "reason_codes": ["status_blocked"]}
	if GameState.active_event_id != "":
		return {"type": "none", "reason_codes": ["active_event_present"]}

	var eligible: Array = []
	for meta in CANDIDATES:
		var score_result := _score(meta)
		if score_result["eligible"]:
			eligible.append({"meta": meta, "score": score_result["score"], "reasons": score_result["reasons"]})

	if eligible.is_empty():
		return {"type": "none", "reason_codes": ["no_eligible_event"]}

	if GameState.director_advisory_pending != "":
		for e in eligible:
			if e["meta"]["event_id"] == GameState.director_advisory_pending:
				return {
					"type": "trigger",
					"event_id": e["meta"]["event_id"],
					"reason_codes": e["reasons"] + ["advisory_fulfilled"],
				}

	eligible.sort_custom(func(a, b): return a["score"] > b["score"])
	var best: Dictionary = eligible[0]

	if GameState.predictability == GameState.Predictability.HIGH:
		if GameState.director_advisory_pending != best["meta"]["event_id"]:
			return {
				"type": "advisory",
				"event_id": best["meta"]["event_id"],
				"reason_codes": best["reasons"] + ["high_predictability_advisory"],
			}

	return {
		"type": "trigger",
		"event_id": best["meta"]["event_id"],
		"reason_codes": best["reasons"],
	}


static func _score(meta: Dictionary) -> Dictionary:
	var reasons: Array[String] = []
	var event_id: String = meta["event_id"]
	if event_id in GameState.triggered_event_ids:
		return {"eligible": false, "score": 0, "reasons": ["already_triggered"]}
	if GameState.director_cooldown > 0:
		return {"eligible": false, "score": 0, "reasons": ["cooldown"]}
	if GameState.turn < int(meta.get("min_turn", 1)):
		return {"eligible": false, "score": 0, "reasons": ["min_turn"]}
	var cost := int(meta.get("intensity", INTENSITY_COST))
	if GameState.director_intensity < cost:
		return {"eligible": false, "score": 0, "reasons": ["intensity"]}

	var score := 40
	reasons.append("base")

	var tags: Array = meta.get("affinity_tags", [])
	for eq_id in GameState.active_loadout:
		var def := CraftingEngine.get_definition(eq_id)
		for t in def.get("tags", []):
			if t in tags:
				score += 15
				reasons.append("loadout_affinity")
				break

	if not GameState.director_history.is_empty():
		var last: Dictionary = GameState.director_history[GameState.director_history.size() - 1]
		if last.get("category", "") == meta.get("category", ""):
			score -= 50
			reasons.append("category_repeat")

	var threshold := 15
	match GameState.predictability:
		GameState.Predictability.HIGH:
			threshold += 12
		GameState.Predictability.UNPREDICTABLE:
			threshold -= 8
		_:
			pass
	if score < threshold:
		return {"eligible": false, "score": score, "reasons": reasons + ["below_threshold"]}

	var rng := RandomNumberGenerator.new()
	rng.seed = _director_seed() ^ event_id.hash()
	score += rng.randi_range(0, 8)
	return {"eligible": true, "score": score, "reasons": reasons}


static func _director_seed() -> int:
	var h := GameState.director_history.size()
	return (GameState.seed ^ (GameState.turn * 2654435761) ^ (h * 40503) ^ (GameState.pivot_count * 97)) & 0x7fffffff


static func _apply_trigger(event_id: String, reasons: Array) -> void:
	var meta := {}
	for m in CANDIDATES:
		if m["event_id"] == event_id:
			meta = m
			break
	var cost := int(meta.get("intensity", INTENSITY_COST))
	GameState.director_intensity = maxi(0, GameState.director_intensity - cost)
	GameState.director_cooldown = COOLDOWN_AFTER_TRIGGER
	GameState.director_advisory_pending = ""
	GameState.advisory_text = ""
	GameState.director_history.append({
		"event_id": event_id,
		"category": meta.get("category", "unknown"),
		"turn": GameState.turn,
		"reasons": reasons,
	})
	GameState.append_log("Director triggered: %s" % event_id)
	SupplyLineMission.open_pivot(event_id)
