class_name PivotLibrary
extends RefCounted
## Pre-authored Pivot Events. Director selects; never invents prose.


static func get_event(event_id: String) -> Dictionary:
	for e in list_all():
		if e["id"] == event_id:
			return e
	return {}


static func list_all() -> Array:
	return [
		_bridge_destroyed(),
		_supplies_delayed(),
		_scout_missing(),
		_weather_changes(),
		_new_information(),
		_ally_offers_help(),
	]


static func _choice(id: String, label: String, description: String, action: String, extras: Dictionary = {}) -> Dictionary:
	var c := {
		"id": id,
		"label": label,
		"description": description,
		"action_type": action,
		"require_equipment": [],
		"consume_equipment": [],
		"effects": [],
	}
	for k in extras:
		c[k] = extras[k]
	return c


static func _bridge_destroyed() -> Dictionary:
	return {
		"id": "bridge-destroyed",
		"title": "BRIDGE DESTROYED",
		"status": "The route to Highwatch is blocked.",
		"flavor": "RIVER CROSSING SUNDERED. A critical connection is severed. Trade is stalled.",
		"category": "route",
		"world_change": "destroyed_bridge",
		"choices": [
			_choice(
				"bd-repair",
				"Repair the bridge",
				"Spend materials to restore the span.",
				"repair",
				{"effects": [{"type": "spend_materials", "amount": 2}, {"type": "flag", "key": "crossing_repaired"}, {"type": "unblock_crossing"}, {"type": "resume_mission"}]}
			),
			_choice(
				"bd-ask",
				"Ask the village for help",
				"Call on Oakhaven for labour and timber.",
				"ask",
				{"effects": [{"type": "spend_influence", "amount": 1}, {"type": "flag", "key": "village_helped"}, {"type": "unblock_crossing"}, {"type": "resume_mission"}]}
			),
			_choice(
				"bd-reroute",
				"Find another route",
				"Take the eastern track through the hills.",
				"reroute",
				{"effects": [{"type": "add_turns", "amount": 2}, {"type": "flag", "key": "took_eastern"}, {"type": "flag", "key": "bypass_crossing"}, {"type": "resume_mission"}]}
			),
			_choice(
				"bd-adapt",
				"Make my own plan",
				"Hold, observe, and write a new approach — then press via the hills.",
				"adapt",
				{"effects": [{"type": "gain_intel", "amount": 1}, {"type": "flag", "key": "adapted_at_crossing"}, {"type": "flag", "key": "bypass_crossing"}, {"type": "resume_mission"}]}
			),
			_choice(
				"bd-build-kit",
				"Deploy Field Bridge Kit",
				"Lay a temporary span from your loadout.",
				"build",
				{
					"require_equipment": ["field-bridge-kit"],
					"consume_equipment": ["field-bridge-kit"],
					"effects": [{"type": "flag", "key": "bridge_built"}, {"type": "unblock_crossing"}, {"type": "resume_mission"}],
				}
			),
			_choice(
				"bd-repair-kit",
				"Use Repair Kit",
				"Brace and clear the span without extra materials.",
				"repair",
				{
					"require_equipment": ["repair-kit"],
					"consume_equipment": ["repair-kit"],
					"effects": [{"type": "flag", "key": "crossing_repaired"}, {"type": "unblock_crossing"}, {"type": "resume_mission"}],
				}
			),
			_choice(
				"bd-radio",
				"Radio for a guide",
				"Raise a local contact who knows the ford.",
				"ask",
				{
					"require_equipment": ["portable-radio"],
					"consume_equipment": [],
					"effects": [{"type": "flag", "key": "radio_guide"}, {"type": "flag", "key": "discovered_ford"}, {"type": "flag", "key": "bypass_crossing"}, {"type": "resume_mission"}],
				}
			),
			_choice(
				"bd-recon-kit",
				"Survey with Recon Kit",
				"Map the ford and eastern approach in detail.",
				"recon",
				{
					"require_equipment": ["recon-kit"],
					"consume_equipment": [],
					"effects": [{"type": "gain_intel", "amount": 1}, {"type": "flag", "key": "discovered_ford"}, {"type": "flag", "key": "revealed_eastern"}, {"type": "flag", "key": "bypass_crossing"}, {"type": "resume_mission"}],
				}
			),
			_choice(
				"bd-markers",
				"Mark the eastern track",
				"Plant Route Markers and divert the column.",
				"reroute",
				{
					"require_equipment": ["route-markers"],
					"consume_equipment": ["route-markers"],
					"effects": [{"type": "add_turns", "amount": 1}, {"type": "flag", "key": "took_eastern"}, {"type": "flag", "key": "bypass_crossing"}, {"type": "resume_mission"}],
				}
			),
			_choice(
				"bd-cache",
				"Open Supply Cache",
				"Recover materials, then choose again.",
				"supply",
				{
					"require_equipment": ["supply-cache"],
					"consume_equipment": ["supply-cache"],
					"effects": [{"type": "gain_materials", "amount": 2}, {"type": "reopen_pivot"}],
				}
			),
		],
	}


static func _supplies_delayed() -> Dictionary:
	return {
		"id": "supplies-delayed",
		"title": "SUPPLIES DELAYED",
		"status": "The wagon train has not arrived.",
		"flavor": "Crates sit elsewhere. The column must decide how to wait.",
		"category": "resource",
		"world_change": "supply_delay",
		"choices": [
			_choice("sd-wait", "Wait for delivery", "Skip a beat and hold position.", "hold", {"effects": [{"type": "add_turns", "amount": 1}, {"type": "resume_mission"}]}),
			_choice("sd-forage", "Forage nearby", "Spend time; gain a little material.", "adapt", {"effects": [{"type": "add_turns", "amount": 1}, {"type": "gain_materials", "amount": 1}, {"type": "resume_mission"}]}),
			_choice("sd-adapt", "Press on light", "Continue without the delayed stores.", "adapt", {"effects": [{"type": "flag", "key": "travel_light"}, {"type": "resume_mission"}]}),
		],
	}


static func _scout_missing() -> Dictionary:
	return {
		"id": "scout-missing",
		"title": "SCOUT MISSING",
		"status": "Your forward eye has gone quiet.",
		"flavor": "A telescope and map lie on the Ironpeak path.",
		"category": "recon",
		"world_change": "scout_missing",
		"choices": [
			_choice("sm-search", "Search", "Spend a turn looking along the ridge.", "recon", {"effects": [{"type": "add_turns", "amount": 1}, {"type": "gain_intel", "amount": 1}, {"type": "resume_mission"}]}),
			_choice("sm-hunker", "Hunker down", "Fortify and wait for contact.", "hold", {"effects": [{"type": "flag", "key": "fortified"}, {"type": "resume_mission"}]}),
			_choice("sm-messenger", "Send messenger", "Spend influence to raise the line.", "ask", {"effects": [{"type": "spend_influence", "amount": 1}, {"type": "resume_mission"}]}),
		],
	}


static func _weather_changes() -> Dictionary:
	return {
		"id": "weather-changes",
		"title": "WEATHER CHANGES",
		"status": "A front rolls over the Kingsroad.",
		"flavor": "Rain hardens the choice between speed and care.",
		"category": "weather",
		"world_change": "weather",
		"choices": [
			_choice("wc-march", "March through storm", "Slow going; learn the road.", "adapt", {"effects": [{"type": "add_turns", "amount": 1}, {"type": "gain_intel", "amount": 1}, {"type": "resume_mission"}]}),
			_choice("wc-rest", "Rest", "Wait out the worst of it.", "hold", {"effects": [{"type": "add_turns", "amount": 1}, {"type": "resume_mission"}]}),
			_choice("wc-intel", "Gather intel", "Use the pause to listen.", "recon", {"effects": [{"type": "gain_intel", "amount": 1}, {"type": "resume_mission"}]}),
		],
	}


static func _new_information() -> Dictionary:
	return {
		"id": "new-information",
		"title": "NEW INFORMATION",
		"status": "A sealed report reaches the column.",
		"flavor": "Rumours and facts share the same parchment.",
		"category": "intel",
		"world_change": "new_intel",
		"choices": [
			_choice("ni-decode", "Decode", "Spend insight to clarify the map.", "recon", {"effects": [{"type": "spend_intel", "amount": 1}, {"type": "flag", "key": "decoded_report"}, {"type": "resume_mission"}]}),
			_choice("ni-trade", "Trade info", "Spend influence for a cleaner reading.", "ask", {"effects": [{"type": "spend_influence", "amount": 1}, {"type": "gain_intel", "amount": 1}, {"type": "resume_mission"}]}),
			_choice("ni-ignore", "Press on", "File it and keep moving.", "adapt", {"effects": [{"type": "resume_mission"}]}),
		],
	}


static func _ally_offers_help() -> Dictionary:
	return {
		"id": "ally-offers-help",
		"title": "ALLY OFFERS HELP",
		"status": "A friendly banner approaches.",
		"flavor": "Help arrives — on terms you can shape.",
		"category": "ally",
		"world_change": "ally",
		"choices": [
			_choice("ah-troops", "Accept escort", "Gain a safer march.", "ask", {"effects": [{"type": "flag", "key": "escort"}, {"type": "resume_mission"}]}),
			_choice("ah-supplies", "Request supplies", "Gain materials.", "supply", {"effects": [{"type": "gain_materials", "amount": 2}, {"type": "resume_mission"}]}),
			_choice("ah-tribute", "Ask for coin-equivalent", "Gain materials; lose a little goodwill.", "adapt", {"effects": [{"type": "gain_materials", "amount": 3}, {"type": "flag", "key": "reputation_strain"}, {"type": "resume_mission"}]}),
		],
	}
