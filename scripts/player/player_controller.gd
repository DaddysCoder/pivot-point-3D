extends CharacterBody3D
## Third-person operator controller — Phase 1 game feel.

const WALK_SPEED := 3.4
const RUN_SPEED := 5.6
const SPRINT_SPEED := 7.8
const ACCELERATION := 14.0
const FRICTION := 16.0
const GRAVITY := 22.0
const ROTATION_SPEED := 12.0

@export var camera_path: NodePath

@onready var mesh: Node3D = $MeshPivot
@onready var interaction: InteractionController = $InteractionController

var _camera: FollowCamera
var _wish_dir := Vector3.ZERO


func _ready() -> void:
	if camera_path != NodePath():
		_camera = get_node(camera_path) as FollowCamera
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if GameState.input_locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return
	_apply_gravity(delta)
	_read_move_input()
	_apply_movement(delta)
	_face_move_direction(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif velocity.y < 0.0:
		velocity.y = -0.5


func _read_move_input() -> void:
	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis_yaw := _camera.get_yaw_basis() if _camera else global_transform.basis
	var forward := -basis_yaw.z
	var right := basis_yaw.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	_wish_dir = (right * input_2d.x + forward * -input_2d.y)
	if _wish_dir.length_squared() > 1.0:
		_wish_dir = _wish_dir.normalized()


func _target_speed() -> float:
	if _wish_dir == Vector3.ZERO:
		return 0.0
	if Input.is_action_pressed("sprint"):
		return SPRINT_SPEED
	# Slight stick/keyboard magnitude: walk when gentle, run when committed.
	var strength := Input.get_vector("move_left", "move_right", "move_forward", "move_back").length()
	if strength < 0.55:
		return WALK_SPEED
	return RUN_SPEED


func _apply_movement(delta: float) -> void:
	var target := _wish_dir * _target_speed()
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if _wish_dir == Vector3.ZERO:
		horizontal = horizontal.move_toward(Vector3.ZERO, FRICTION * delta)
	else:
		horizontal = horizontal.move_toward(target, ACCELERATION * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z


func _face_move_direction(delta: float) -> void:
	if _wish_dir.length_squared() < 0.01:
		return
	var target_yaw := atan2(-_wish_dir.x, -_wish_dir.z)
	mesh.rotation.y = lerp_angle(mesh.rotation.y, target_yaw, 1.0 - exp(-ROTATION_SPEED * delta))
