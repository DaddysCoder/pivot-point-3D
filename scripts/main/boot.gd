extends Control
## Boot title — brand over concept art.


@onready var bg: TextureRect = $BgArt
@onready var title: Label = $VBox/Title
@onready var tag: Label = $VBox/Tag
@onready var begin_btn: Button = $VBox/Begin
@onready var feel_btn: Button = $VBox/FeelTest
@onready var options_btn: Button = $VBox/Options
@onready var facilitator_btn: Button = $VBox/Facilitator


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var tex := ArtCatalog.texture(ArtCatalog.CHAR_SELECT)
	if tex:
		bg.texture = tex
	ArtCatalog.style_ink_label(title, 48)
	title.add_theme_color_override("font_color", Color(0.95, 0.90, 0.78, 1))
	ArtCatalog.style_ink_label(tag, 20, true)
	tag.add_theme_color_override("font_color", Color(0.90, 0.84, 0.70, 1))
	ArtCatalog.style_button(begin_btn)
	ArtCatalog.style_button(feel_btn)
	ArtCatalog.style_button(options_btn)
	ArtCatalog.style_button(facilitator_btn)


func _on_begin_pressed() -> void:
	GameState.reset_campaign()
	if GameSettings.onboarding_seen:
		SceneRouter.to_character_select()
	else:
		SceneRouter.to_onboarding()


func _on_feel_test_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/test_environment.tscn")


func _on_options_pressed() -> void:
	OptionsMenu.open(self, false)


func _on_facilitator_pressed() -> void:
	SceneRouter.to_facilitator_profiles()
