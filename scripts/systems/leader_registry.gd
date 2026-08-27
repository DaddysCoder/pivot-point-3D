class_name LeaderRegistry
extends RefCounted
## Six selectable leaders from the concept pack.


static func list_all() -> Array:
	return [
		{
			"id": "strategist",
			"role": "Strategist",
			"name": "Marcus",
			"blurb": "Reads the map before the road does.",
			"bonus": "start_intel",
		},
		{
			"id": "scout",
			"role": "Scout",
			"name": "Li",
			"blurb": "Finds the path the column has not named yet.",
			"bonus": "start_recon",
		},
		{
			"id": "engineer",
			"role": "Engineer",
			"name": "Elias",
			"blurb": "Turns timber and iron into options.",
			"bonus": "start_materials",
		},
		{
			"id": "diplomat",
			"role": "Diplomat",
			"name": "Amina",
			"blurb": "Opens doors the sealed road cannot.",
			"bonus": "start_influence",
		},
		{
			"id": "historian",
			"role": "Historian",
			"name": "Elara",
			"blurb": "Keeps the record when rumours compete.",
			"bonus": "start_intel",
		},
		{
			"id": "builder",
			"role": "Builder",
			"name": "Kael",
			"blurb": "Raises what the crossing needs.",
			"bonus": "start_materials",
		},
	]


static func apply_starting_bonus(leader_id: String) -> void:
	match leader_id:
		"strategist", "historian":
			GameState.intel += 1
		"engineer", "builder":
			GameState.materials += 2
		"diplomat":
			GameState.influence += 1
		"scout":
			GameState.intel += 1
			GameState.materials += 1
		_:
			pass
	GameState.resources_changed.emit()
