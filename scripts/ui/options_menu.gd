class_name OptionsMenu
extends CanvasLayer
## Accessibility / play-style options overlay. Reachable from Boot and as an
## in-game pause menu. Exposes the existing GameSettings toggles plus the
## high-visibility cursor size setting.

signal closed

static var current: OptionsMenu = null

@export var pause_game: bool = false

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/VBox/Title
@onready var reduced_camera: CheckButton = $Panel/Margin/VBox/CameraRow/ReducedCamera
@onready var invert_y: CheckButton = $Panel/Margin/VBox/InvertYRow/InvertY
@onready var large_cursor: CheckButton = $Panel/Margin/VBox/CursorRow/LargeCursor
@onready var sensitivity_slider: HSlider = $Panel/Margin/VBox/SensitivityRow/Sensitivity
@onready var sensitivity_value: Label = $Panel/Margin/VBox/SensitivityRow/Value
@onready var close_btn: Button = $Panel/Margin/VBox/Close


## Instances and opens the options overlay under `parent`. When `pause`
## is true, the scene tree is paused and the overlay keeps processing.
static func open(parent: Node, pause: bool = false) -> OptionsMenu:
	if current:
		return current
	var scene := load("res://scenes/ui/options_menu.tscn") as PackedScene
	var menu := scene.instantiate() as OptionsMenu
	menu.pause_game = pause
	current = menu
	parent.add_child(menu)
	return menu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.style_ink_label(title, 26)
	for label in [$Panel/Margin/VBox/CameraRow/Label, $Panel/Margin/VBox/InvertYRow/Label,
			$Panel/Margin/VBox/CursorRow/Label, $Panel/Margin/VBox/SensitivityRow/Label]:
		ArtCatalog.style_ink_label(label, 16, true)
	ArtCatalog.style_ink_label(sensitivity_value, 16, true)
	ArtCatalog.style_button(close_btn)
	ArtCatalog.style_button(reduced_camera)
	ArtCatalog.style_button(invert_y)
	ArtCatalog.style_button(large_cursor)

	reduced_camera.button_pressed = GameSettings.is_reduced_camera()
	invert_y.button_pressed = GameSettings.invert_y
	large_cursor.button_pressed = GameSettings.cursor_size == GameSettings.CursorSize.LARGE
	sensitivity_slider.min_value = 0.02
	sensitivity_slider.max_value = 0.30
	sensitivity_slider.step = 0.01
	sensitivity_slider.value = GameSettings.mouse_sensitivity
	_refresh_sensitivity_label()

	reduced_camera.toggled.connect(_on_reduced_camera_toggled)
	invert_y.toggled.connect(_on_invert_y_toggled)
	large_cursor.toggled.connect(_on_large_cursor_toggled)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	close_btn.pressed.connect(close)

	if pause_game:
		get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		close()
		get_viewport().set_input_as_handled()


func close() -> void:
	if pause_game:
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if current == self:
		current = null
	closed.emit()
	queue_free()


func _on_reduced_camera_toggled(pressed: bool) -> void:
	GameSettings.camera_motion = GameSettings.CameraMotion.REDUCED if pressed else GameSettings.CameraMotion.STANDARD


func _on_invert_y_toggled(pressed: bool) -> void:
	GameSettings.invert_y = pressed


func _on_large_cursor_toggled(pressed: bool) -> void:
	GameSettings.cursor_size = GameSettings.CursorSize.LARGE if pressed else GameSettings.CursorSize.STANDARD


func _on_sensitivity_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
	_refresh_sensitivity_label()


func _refresh_sensitivity_label() -> void:
	sensitivity_value.text = "%.2f" % GameSettings.mouse_sensitivity
