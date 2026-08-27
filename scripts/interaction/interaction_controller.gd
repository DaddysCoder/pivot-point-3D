class_name InteractionController
extends Node3D
## Finds nearby Interactables and routes the interact action. Not object-specific.

signal focus_changed(interactable: Interactable)
signal prompt_changed(text: String)

@export var reach_radius := 2.4
@export var owner_body_path: NodePath

var _focus: Interactable
var _owner_body: Node3D
@onready var _probe: Area3D = $Probe


func _ready() -> void:
	if owner_body_path != NodePath():
		_owner_body = get_node(owner_body_path)
	else:
		_owner_body = get_parent() as Node3D
	_probe.collision_layer = 0
	_probe.collision_mask = 4
	_probe.monitoring = true
	_probe.monitorable = false


func _physics_process(_delta: float) -> void:
	_update_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _focus and _focus.can_interact(_owner_body):
		_focus.interact(_owner_body)
		get_viewport().set_input_as_handled()


func _update_focus() -> void:
	var best: Interactable = null
	var best_score := -INF
	for body in _probe.get_overlapping_areas():
		if body is Interactable:
			var interactable := body as Interactable
			if not interactable.can_interact(_owner_body):
				continue
			var to := interactable.global_position - global_position
			var dist := to.length()
			if dist > reach_radius:
				continue
			# Prefer closer + more in front of player facing.
			var facing := -_owner_body.global_transform.basis.z
			facing.y = 0.0
			facing = facing.normalized()
			var dir := to
			dir.y = 0.0
			if dir.length_squared() > 0.001:
				dir = dir.normalized()
			var align := facing.dot(dir)
			var score := align * 2.0 - dist
			if score > best_score:
				best_score = score
				best = interactable
	if best != _focus:
		_focus = best
		focus_changed.emit(_focus)
		if _focus:
			prompt_changed.emit(_focus.get_prompt(_owner_body))
		else:
			prompt_changed.emit("")


func get_focus() -> Interactable:
	return _focus
