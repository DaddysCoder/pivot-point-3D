class_name OptionsMenu
extends CanvasLayer
## Play Style / accessibility overlay. Reachable from Boot and as an in-game
## pause menu. Exposes predictability, decision load, time pressure,
## information style, motion, transitions, sound, and the cursor settings —
## parity with the 2D reference build's PlayStyleSettings screen.

signal closed

static var current: OptionsMenu = null

@export var pause_game: bool = false

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var title: Label = $Panel/Margin/Outer/Title

@onready var predictability: OptionButton = $Panel/Margin/Outer/Scroll/VBox/PredictabilityRow/Predictability
@onready var decision_load: OptionButton = $Panel/Margin/Outer/Scroll/VBox/DecisionLoadRow/DecisionLoad
@onready var time_pressure: OptionButton = $Panel/Margin/Outer/Scroll/VBox/TimePressureRow/TimePressure
@onready var information_style: OptionButton = $Panel/Margin/Outer/Scroll/VBox/InformationStyleRow/InformationStyle
@onready var reduced_camera: CheckButton = $Panel/Margin/Outer/Scroll/VBox/CameraRow/ReducedCamera
@onready var transition: OptionButton = $Panel/Margin/Outer/Scroll/VBox/TransitionRow/Transition
@onready var invert_y: CheckButton = $Panel/Margin/Outer/Scroll/VBox/InvertYRow/InvertY
@onready var large_cursor: CheckButton = $Panel/Margin/Outer/Scroll/VBox/CursorRow/LargeCursor
@onready var sensitivity_slider: HSlider = $Panel/Margin/Outer/Scroll/VBox/SensitivityRow/Sensitivity
@onready var sensitivity_value: Label = $Panel/Margin/Outer/Scroll/VBox/SensitivityRow/Value
@onready var music: CheckButton = $Panel/Margin/Outer/Scroll/VBox/SoundRow/Music
@onready var effects: CheckButton = $Panel/Margin/Outer/Scroll/VBox/SoundRow/Effects
@onready var alerts: CheckButton = $Panel/Margin/Outer/Scroll/VBox/SoundRow/Alerts
@onready var calm_note: Label = $Panel/Margin/Outer/Scroll/VBox/CalmNote
@onready var sound_label: Label = $Panel/Margin/Outer/Scroll/VBox/SoundLabel
@onready var close_btn: Button = $Panel/Margin/Outer/Close

## Built in _ready() (not as top-level consts) so autoload enum values are
## resolved at runtime, after GameState/GameSettings are guaranteed loaded.
var PREDICTABILITY_OPTIONS: Array = []
var DECISION_LOAD_OPTIONS: Array = []
var TIME_PRESSURE_OPTIONS: Array = []
var INFORMATION_STYLE_OPTIONS: Array = []
var TRANSITION_OPTIONS: Array = []


func _build_option_tables() -> void:
	PREDICTABILITY_OPTIONS = [
		{"value": GameState.Predictability.HIGH, "label": "High — advance notice"},
		{"value": GameState.Predictability.BALANCED, "label": "Balanced"},
		{"value": GameState.Predictability.UNPREDICTABLE, "label": "Unpredictable"},
	]
	DECISION_LOAD_OPTIONS = [
		{"value": 2, "label": "2 choices"},
		{"value": 3, "label": "3 choices"},
		{"value": 4, "label": "4 choices"},
		{"value": GameSettings.DECISION_LOAD_OPEN, "label": "Open strategy"},
	]
	TIME_PRESSURE_OPTIONS = [
		{"value": GameSettings.TimePressure.NONE, "label": "None (default)"},
		{"value": GameSettings.TimePressure.GENTLE, "label": "Gentle"},
		{"value": GameSettings.TimePressure.TACTICAL, "label": "Tactical"},
	]
	INFORMATION_STYLE_OPTIONS = [
		{"value": GameSettings.InformationStyle.SHORT, "label": "Short"},
		{"value": GameSettings.InformationStyle.STANDARD, "label": "Standard"},
		{"value": GameSettings.InformationStyle.DETAILED, "label": "Detailed"},
	]
	TRANSITION_OPTIONS = [
		{"value": GameSettings.TransitionWarning.IMMEDIATE, "label": "Immediate"},
		{"value": GameSettings.TransitionWarning.WARN_10S, "label": "10-second warning"},
		{"value": GameSettings.TransitionWarning.WARN_30S, "label": "30-second warning"},
		{"value": GameSettings.TransitionWarning.PLAYER, "label": "Player-controlled continue"},
	]


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
	for row in [
		$Panel/Margin/Outer/Scroll/VBox/PredictabilityRow, $Panel/Margin/Outer/Scroll/VBox/DecisionLoadRow,
		$Panel/Margin/Outer/Scroll/VBox/TimePressureRow, $Panel/Margin/Outer/Scroll/VBox/InformationStyleRow,
		$Panel/Margin/Outer/Scroll/VBox/CameraRow, $Panel/Margin/Outer/Scroll/VBox/TransitionRow,
		$Panel/Margin/Outer/Scroll/VBox/InvertYRow, $Panel/Margin/Outer/Scroll/VBox/CursorRow,
		$Panel/Margin/Outer/Scroll/VBox/SensitivityRow,
	]:
		ArtCatalog.style_ink_label(row.get_node("Label") as Label, 16, true)
	ArtCatalog.style_ink_label(sound_label, 16, true)
	ArtCatalog.style_ink_label(sensitivity_value, 16, true)
	ArtCatalog.style_ink_label(calm_note, 13, true)
	ArtCatalog.style_button(close_btn)
	ArtCatalog.style_button(music)
	ArtCatalog.style_button(effects)
	ArtCatalog.style_button(alerts)
	ArtCatalog.style_button(reduced_camera)
	ArtCatalog.style_button(invert_y)
	ArtCatalog.style_button(large_cursor)

	_build_option_tables()
	_populate_option_button(predictability, PREDICTABILITY_OPTIONS, GameState.predictability)
	_populate_option_button(decision_load, DECISION_LOAD_OPTIONS, GameSettings.decision_load)
	_populate_option_button(time_pressure, TIME_PRESSURE_OPTIONS, GameSettings.time_pressure)
	_populate_option_button(information_style, INFORMATION_STYLE_OPTIONS, GameSettings.information_style)
	_populate_option_button(transition, TRANSITION_OPTIONS, GameSettings.transition_warning)

	reduced_camera.button_pressed = GameSettings.is_reduced_camera()
	invert_y.button_pressed = GameSettings.invert_y
	large_cursor.button_pressed = GameSettings.cursor_size == GameSettings.CursorSize.LARGE
	music.button_pressed = GameSettings.music_enabled
	effects.button_pressed = GameSettings.effects_enabled
	alerts.button_pressed = GameSettings.alerts_enabled
	sensitivity_slider.min_value = 0.02
	sensitivity_slider.max_value = 0.30
	sensitivity_slider.step = 0.01
	sensitivity_slider.value = GameSettings.mouse_sensitivity
	_refresh_sensitivity_label()

	predictability.item_selected.connect(_on_predictability_selected)
	decision_load.item_selected.connect(_on_decision_load_selected)
	time_pressure.item_selected.connect(_on_time_pressure_selected)
	information_style.item_selected.connect(_on_information_style_selected)
	transition.item_selected.connect(_on_transition_selected)
	reduced_camera.toggled.connect(_on_reduced_camera_toggled)
	invert_y.toggled.connect(_on_invert_y_toggled)
	large_cursor.toggled.connect(_on_large_cursor_toggled)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	music.toggled.connect(func(pressed): GameSettings.music_enabled = pressed)
	effects.toggled.connect(func(pressed): GameSettings.effects_enabled = pressed)
	alerts.toggled.connect(func(pressed): GameSettings.alerts_enabled = pressed)
	close_btn.pressed.connect(close)

	if pause_game:
		get_tree().paused = true


func _populate_option_button(control: OptionButton, options: Array, current_value) -> void:
	control.clear()
	var selected_index := 0
	for i in options.size():
		var opt: Dictionary = options[i]
		control.add_item(str(opt["label"]), i)
		if opt["value"] == current_value:
			selected_index = i
	control.select(selected_index)


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


func _on_predictability_selected(index: int) -> void:
	GameState.predictability = PREDICTABILITY_OPTIONS[index]["value"]


func _on_decision_load_selected(index: int) -> void:
	GameSettings.decision_load = DECISION_LOAD_OPTIONS[index]["value"]


func _on_time_pressure_selected(index: int) -> void:
	GameSettings.time_pressure = TIME_PRESSURE_OPTIONS[index]["value"]


func _on_information_style_selected(index: int) -> void:
	GameSettings.information_style = INFORMATION_STYLE_OPTIONS[index]["value"]


func _on_transition_selected(index: int) -> void:
	GameSettings.transition_warning = TRANSITION_OPTIONS[index]["value"]


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
