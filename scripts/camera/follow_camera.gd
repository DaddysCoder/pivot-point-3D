class_name FollowCamera
extends Node3D
## Third-person follow camera with SpringArm collision and accessibility smoothing.

@export var target_path: NodePath
@export var shoulder_offset := Vector3(0.45, 1.55, 0.0)
@export var arm_length := 4.2
@export var min_pitch := -55.0
@export var max_pitch := 35.0

@onready var yaw_pivot: Node3D = $YawPivot
@onready var pitch_pivot: Node3D = $YawPivot/PitchPivot
@onready var spring: SpringArm3D = $YawPivot/PitchPivot/SpringArm3D
@onready var camera: Camera3D = $YawPivot/PitchPivot/SpringArm3D/Camera3D

var _target: Node3D
var _yaw := 0.0
var _pitch := -12.0


func _ready() -> void:
	if target_path != NodePath():
		_target = get_node(target_path)
	spring.spring_length = arm_length
	spring.collision_mask = 1 # world
	spring.margin = 0.2
	camera.current = true
	_apply_rotation()


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		var sens: float = GameSettings.mouse_sensitivity
		_yaw -= motion.relative.x * sens * 0.01 * TAU
		var y_sign := -1.0 if GameSettings.invert_y else 1.0
		_pitch -= motion.relative.y * sens * 0.01 * TAU * y_sign
		_pitch = clampf(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		_apply_rotation()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("camera_reset") and _target:
		_yaw = _target.global_rotation.y
		_pitch = deg_to_rad(-12.0)
		_apply_rotation()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_apply_gamepad_look(delta)
	if _target == null:
		return
	var desired := _target.global_position + shoulder_offset
	var weight := GameSettings.camera_smooth_weight(delta)
	global_position = global_position.lerp(desired, weight)


func _apply_gamepad_look(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var look := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if look.length() < 0.15:
		return
	var sens: float = GameSettings.gamepad_look_sensitivity
	_yaw -= look.x * sens * delta
	var y_sign := -1.0 if GameSettings.invert_y else 1.0
	_pitch -= look.y * sens * delta * y_sign
	_pitch = clampf(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	_apply_rotation()


func _apply_rotation() -> void:
	yaw_pivot.rotation.y = _yaw
	pitch_pivot.rotation.x = _pitch


func get_yaw_basis() -> Basis:
	return Basis(Vector3.UP, _yaw)
