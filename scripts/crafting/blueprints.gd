class_name BlueprintRegistry
extends RefCounted
## Six strategic kits — optional solutions only.


static func list_all() -> Array:
	return [
		{
			"id": "field-bridge-kit",
			"name": "Field Bridge Kit",
			"description": "Deployable components for temporary crossings.",
			"purpose": "Spans a damaged crossing long enough for the column to pass.",
			"material_cost": 5,
			"intel_cost": 0,
			"tags": ["build", "crossing"],
			"consumed_on_use": true,
		},
		{
			"id": "repair-kit",
			"name": "Repair Kit",
			"description": "Field tools and bracing for equipment repair.",
			"purpose": "Restores damaged fittings when the situation allows.",
			"material_cost": 3,
			"intel_cost": 0,
			"tags": ["repair"],
			"consumed_on_use": true,
		},
		{
			"id": "recon-kit",
			"name": "Recon Kit",
			"description": "Optics and survey tools for closer observation.",
			"purpose": "Pulls additional terrain detail when the map goes quiet.",
			"material_cost": 3,
			"intel_cost": 1,
			"tags": ["recon"],
			"consumed_on_use": false,
		},
		{
			"id": "portable-radio",
			"name": "Portable Radio",
			"description": "Handset and antenna for short-range contact.",
			"purpose": "Keeps another line of communication open when plans change.",
			"material_cost": 2,
			"intel_cost": 0,
			"tags": ["ask", "comms"],
			"consumed_on_use": false,
		},
		{
			"id": "supply-cache",
			"name": "Supply Cache",
			"description": "Compact stores for one shortfall on the road.",
			"purpose": "Offsets a single compatible resource shortage in the field.",
			"material_cost": 4,
			"intel_cost": 0,
			"tags": ["supply"],
			"consumed_on_use": true,
		},
		{
			"id": "route-markers",
			"name": "Route Markers",
			"description": "Flags and notes for marking an alternate path.",
			"purpose": "Preserves or reveals an alternate path when the mission supports it.",
			"material_cost": 2,
			"intel_cost": 1,
			"tags": ["route"],
			"consumed_on_use": true,
		},
	]


static func get_by_id(equipment_id: String) -> Dictionary:
	for b in list_all():
		if b["id"] == equipment_id:
			return b
	return {}
