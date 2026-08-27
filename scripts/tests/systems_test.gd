extends Node
## Scene-based systems smoke test (autoload globals available).


func _ready() -> void:
	var failed := 0
	failed += _test_craft_and_loadout()
	failed += _test_bridge_equipment_filter()
	failed += _test_director_disabled()
	failed += _test_director_triggers_when_enabled()
	if failed == 0:
		print("SYSTEMS_TEST_OK")
		get_tree().quit(0)
	else:
		print("SYSTEMS_TEST_FAILED count=", failed)
		get_tree().quit(1)


func _test_craft_and_loadout() -> int:
	GameState.reset_campaign(123)
	GameState.materials = 20
	GameState.intel = 5
	var r := CraftingEngine.craft("field-bridge-kit")
	if not r["ok"]:
		print("FAIL craft bridge")
		return 1
	if GameState.get_owned_quantity("field-bridge-kit") != 1:
		print("FAIL inventory qty")
		return 1
	if GameState.materials != 15:
		print("FAIL materials spent ", GameState.materials)
		return 1
	var e := CraftingEngine.equip("field-bridge-kit")
	if not e["ok"] or not GameState.loadout_has("field-bridge-kit"):
		print("FAIL equip")
		return 1
	print("OK craft_and_loadout")
	return 0


func _test_bridge_equipment_filter() -> int:
	GameState.reset_campaign(99)
	GameState.materials = 20
	GameState.intel = 5
	CraftingEngine.craft("repair-kit")
	CraftingEngine.equip("repair-kit")
	SupplyLineMission.begin()
	SupplyLineMission.open_pivot("bridge-destroyed")
	var ids := GameState.available_choice_ids
	if "bd-repair" not in ids:
		print("FAIL baseline missing")
		return 1
	if "bd-repair-kit" not in ids:
		print("FAIL equipment choice missing ", ids)
		return 1
	if "bd-build-kit" in ids:
		print("FAIL gated kit shown without equip")
		return 1
	print("OK bridge_equipment_filter")
	return 0


func _test_director_disabled() -> int:
	GameState.reset_campaign(7)
	GameState.director_enabled = false
	SupplyLineMission.begin()
	var d := AdaptiveDirector.evaluate()
	if d.get("type", "") != "none":
		print("FAIL director should be off ", d)
		return 1
	print("OK director_disabled")
	return 0


func _test_director_triggers_when_enabled() -> int:
	GameState.reset_campaign(42)
	GameState.director_enabled = true
	GameState.predictability = GameState.Predictability.UNPREDICTABLE
	GameState.director_intensity = 100
	GameState.director_cooldown = 0
	SupplyLineMission.begin()
	GameState.turn = 2
	GameState.triggered_event_ids = ["bridge-destroyed"] as Array[String]
	var d := AdaptiveDirector.evaluate()
	if d.get("type", "") == "none":
		print("FAIL expected trigger/advisory ", d)
		return 1
	print("OK director_triggers_when_enabled ", d.get("type"), " ", d.get("event_id"))
	return 0
