extends Interactable
## Hub station that opens a named UI panel via signal on the hub controller.


@export var station_id: String = "command"


func _on_interact(by: Node3D) -> void:
	var hub := get_tree().get_first_node_in_group("base_hub")
	if hub and hub.has_method("open_station"):
		hub.open_station(station_id, by)
