extends Node3D
## Phase 1 main scene controller — wires prompt UI and settings.


@onready var player: CharacterBody3D = $Player
@onready var prompt: CanvasLayer = $UI/InteractionPrompt
@onready var hint: Label = $UI/HintLabel
@onready var camera_toggle: OptionButton = $UI/SettingsPanel/CameraMotionOption


func _ready() -> void:
	var interaction: InteractionController = player.get_node("InteractionController")
	interaction.prompt_changed.connect(_on_prompt_changed)
	camera_toggle.clear()
	camera_toggle.add_item("Camera: Standard", GameSettings.CameraMotion.STANDARD)
	camera_toggle.add_item("Camera: Reduced", GameSettings.CameraMotion.REDUCED)
	camera_toggle.select(0)
	camera_toggle.item_selected.connect(_on_camera_motion_selected)
	hint.text = "WASD move · Shift sprint · Mouse look · E interact · Esc free cursor · V reset camera"


func _on_prompt_changed(text: String) -> void:
	prompt.set_prompt(text)


func _on_camera_motion_selected(index: int) -> void:
	GameSettings.camera_motion = camera_toggle.get_item_id(index) as GameSettings.CameraMotion
