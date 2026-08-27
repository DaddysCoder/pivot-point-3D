class_name Interactable
extends Area3D
## Base interactable. Extend or configure prompt + signal; keep PlayerController free of object logic.

signal interacted(by: Node3D)

@export var prompt_text: String = "Interact"
@export var enabled: bool = true
@export var one_shot: bool = false

var _used := false


func _ready() -> void:
	monitoring = true
	monitorable = true
	collision_layer = 4 # interactable
	collision_mask = 0
	add_to_group("interactable")


func can_interact(_by: Node3D) -> bool:
	if not enabled:
		return false
	if one_shot and _used:
		return false
	return true


func get_prompt(_by: Node3D) -> String:
	return prompt_text


func interact(by: Node3D) -> void:
	if not can_interact(by):
		return
	_used = true
	interacted.emit(by)
	_on_interact(by)


func _on_interact(_by: Node3D) -> void:
	pass
