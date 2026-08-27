extends Node
## Global play-style / accessibility settings for Pivot Point 3D.

enum CameraMotion { REDUCED, STANDARD }

signal camera_motion_changed(mode: CameraMotion)

var camera_motion: CameraMotion = CameraMotion.STANDARD:
	set(value):
		camera_motion = value
		camera_motion_changed.emit(value)

var mouse_sensitivity: float = 0.12
var gamepad_look_sensitivity: float = 2.4
var invert_y: bool = false


func is_reduced_camera() -> bool:
	return camera_motion == CameraMotion.REDUCED


func camera_smooth_weight(delta: float, standard: float = 12.0, reduced: float = 6.0) -> float:
	var rate := reduced if is_reduced_camera() else standard
	return 1.0 - exp(-rate * delta)
