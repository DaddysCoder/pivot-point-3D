extends Control
## Skippable 4-step briefing before character creation. Sets expectations —
## calm tone, adaptation not punishment — mirroring the 2D reference
## build's OnboardingScreen, adapted to what actually exists in 3D
## (no Frontier/Orbit split, no Mission Master).

const STEPS := [
	{
		"title": "Plans change",
		"body": "Pivot Point is a game about running supply missions where the situation keeps shifting.",
	},
	{
		"title": "Adaptation is the game",
		"body": "When a route closes or intel is wrong, you are not punished — you get new information and choose your next move.",
	},
	{
		"title": "Oakhaven and the Supply Line",
		"body": "Build your operator, then run Supply Line missions out of the Oakhaven Hub. Craft optional kits in the Workshop — they add ways to solve a Pivot, never a requirement.",
	},
	{
		"title": "Play your way",
		"body": "Use Play Style (in Options) to tune predictability, decision load, motion, and sound. Timers are off by default.",
	},
]

@onready var bg: TextureRect = $BgArt
@onready var panel: PanelContainer = $Panel
@onready var step_counter: Label = $Panel/Margin/VBox/StepCounter
@onready var step_title: Label = $Panel/Margin/VBox/StepTitle
@onready var body_panel: PanelContainer = $Panel/Margin/VBox/BodyPanel
@onready var body_label: Label = $Panel/Margin/VBox/BodyPanel/BodyMargin/Body
@onready var continue_btn: Button = $Panel/Margin/VBox/Actions/Continue
@onready var skip_btn: Button = $Panel/Margin/VBox/Actions/Skip

var _step: int = 0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tex := ArtCatalog.texture(ArtCatalog.CHAR_SELECT)
	if tex:
		bg.texture = tex
	ArtCatalog.apply_parchment_panel(panel)
	ArtCatalog.apply_parchment_panel(body_panel)
	ArtCatalog.style_ink_label(step_counter, 12, true)
	ArtCatalog.style_ink_label(step_title, 30)
	ArtCatalog.style_ink_label(body_label, 16)
	ArtCatalog.style_button(continue_btn)
	ArtCatalog.style_button(skip_btn)

	continue_btn.pressed.connect(_on_continue_pressed)
	skip_btn.pressed.connect(_finish)

	_refresh()


func _refresh() -> void:
	var step: Dictionary = STEPS[_step]
	step_counter.text = "BRIEFING %d / %d" % [_step + 1, STEPS.size()]
	step_title.text = str(step["title"])
	body_label.text = str(step["body"])
	continue_btn.text = "Create your operator" if _step == STEPS.size() - 1 else "Continue"


func _on_continue_pressed() -> void:
	if _step < STEPS.size() - 1:
		_step += 1
		_refresh()
	else:
		_finish()


func _finish() -> void:
	GameSettings.onboarding_seen = true
	SceneRouter.to_character_select()
