extends Interactable
## Simple feedback interactable for Phase 1 (mission board / radio / workbench).

@export var status_label_path: NodePath
@export var response_lines: PackedStringArray = PackedStringArray([
	"Orders acknowledged.",
])

var _line_index := 0


func _on_interact(_by: Node3D) -> void:
	if response_lines.is_empty():
		return
	var line := response_lines[_line_index % response_lines.size()]
	_line_index += 1
	if status_label_path != NodePath():
		var status := get_node(status_label_path) as Label3D
		if status:
			status.text = line
