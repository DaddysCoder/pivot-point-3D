extends Node
## Global play-style / accessibility settings for Pivot Point 3D.

enum CameraMotion { REDUCED, STANDARD }
enum CursorSize { STANDARD, LARGE }
enum InformationStyle { SHORT, STANDARD, DETAILED }
enum TimePressure { NONE, GENTLE, TACTICAL }
enum TransitionWarning { IMMEDIATE, WARN_10S, WARN_30S, PLAYER }

## Decision load caps how many baseline (non-equipment) Pivot choices show
## at once. -1 means "open strategy" — no cap. Equipment-gated choices are
## always shown in addition, same as the 2D reference build.
const DECISION_LOAD_OPEN := -1

signal camera_motion_changed(mode: CameraMotion)
signal cursor_size_changed(size: CursorSize)
signal decision_load_changed(load: int)
signal information_style_changed(style: InformationStyle)

var camera_motion: CameraMotion = CameraMotion.STANDARD:
	set(value):
		camera_motion = value
		camera_motion_changed.emit(value)

var cursor_size: CursorSize = CursorSize.STANDARD:
	set(value):
		cursor_size = value
		cursor_size_changed.emit(value)

var mouse_sensitivity: float = 0.12
var gamepad_look_sensitivity: float = 2.4
var invert_y: bool = false

var decision_load: int = 3:
	set(value):
		decision_load = value
		decision_load_changed.emit(value)

var information_style: InformationStyle = InformationStyle.STANDARD:
	set(value):
		information_style = value
		information_style_changed.emit(value)

var time_pressure: TimePressure = TimePressure.NONE
var transition_warning: TransitionWarning = TransitionWarning.PLAYER

var music_enabled: bool = false
var effects_enabled: bool = true
var alerts_enabled: bool = true

## Whether the skippable onboarding briefing has been shown this app
## session. Lives here (not GameState) so it survives reset_campaign().
var onboarding_seen: bool = false


func is_reduced_camera() -> bool:
	return camera_motion == CameraMotion.REDUCED


func camera_smooth_weight(delta: float, standard: float = 12.0, reduced: float = 6.0) -> float:
	var rate := reduced if is_reduced_camera() else standard
	return 1.0 - exp(-rate * delta)
