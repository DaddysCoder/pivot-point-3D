class_name CraftingEngine
extends RefCounted
## Pure crafting helpers. Mutates GameState autoload.


const LOADOUT_LIMIT := 2

static var _blueprints: Dictionary = {}


static func _ensure_blueprints() -> void:
	if not _blueprints.is_empty():
		return
	for b in BlueprintRegistry.list_all():
		_blueprints[b["id"]] = b


static func get_definition(equipment_id: String) -> Dictionary:
	_ensure_blueprints()
	return _blueprints.get(equipment_id, {})


static func list_blueprints() -> Array:
	return BlueprintRegistry.list_all()


static func can_craft(equipment_id: String) -> Dictionary:
	var def := get_definition(equipment_id)
	if def.is_empty():
		return {"ok": false, "reason": "unknown_blueprint"}
	var intel_cost := int(def.get("intel_cost", 0))
	if GameState.materials < int(def["material_cost"]) or GameState.intel < intel_cost:
		return {"ok": false, "reason": "insufficient_resources"}
	return {"ok": true, "reason": ""}


static func craft(equipment_id: String) -> Dictionary:
	var check := can_craft(equipment_id)
	if not check["ok"]:
		return check
	var def := get_definition(equipment_id)
	var intel_cost := int(def.get("intel_cost", 0))
	GameState.materials -= int(def["material_cost"])
	GameState.intel -= intel_cost
	var qty := GameState.get_owned_quantity(equipment_id)
	if qty > 0:
		for e in GameState.inventory:
			if e.get("id", "") == equipment_id:
				e["quantity"] = int(e["quantity"]) + 1
				break
	else:
		GameState.inventory.append({"id": equipment_id, "quantity": 1})
	GameState.resources_changed.emit()
	GameState.inventory_changed.emit()
	return {"ok": true, "reason": ""}


static func equip(equipment_id: String) -> Dictionary:
	if GameState.get_owned_quantity(equipment_id) <= 0:
		return {"ok": false, "reason": "not_owned"}
	if equipment_id in GameState.active_loadout:
		return {"ok": false, "reason": "already_equipped"}
	if GameState.active_loadout.size() >= LOADOUT_LIMIT:
		return {"ok": false, "reason": "loadout_full"}
	GameState.active_loadout.append(equipment_id)
	GameState.loadout_changed.emit()
	return {"ok": true, "reason": ""}


static func unequip(equipment_id: String) -> Dictionary:
	var idx := GameState.active_loadout.find(equipment_id)
	if idx < 0:
		return {"ok": false, "reason": "not_in_loadout"}
	GameState.active_loadout.remove_at(idx)
	GameState.loadout_changed.emit()
	return {"ok": true, "reason": ""}


static func consume(equipment_id: String) -> void:
	var def := get_definition(equipment_id)
	if def.is_empty():
		return
	if not bool(def.get("consumed_on_use", true)):
		return
	for i in range(GameState.inventory.size()):
		var e: Dictionary = GameState.inventory[i]
		if e.get("id", "") != equipment_id:
			continue
		var q := int(e["quantity"]) - 1
		if q <= 0:
			GameState.inventory.remove_at(i)
			var li := GameState.active_loadout.find(equipment_id)
			if li >= 0:
				GameState.active_loadout.remove_at(li)
				GameState.loadout_changed.emit()
		else:
			e["quantity"] = q
		GameState.inventory_changed.emit()
		return


static func consume_list(ids: Array) -> void:
	for id in ids:
		consume(str(id))
