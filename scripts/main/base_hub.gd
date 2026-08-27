extends Node3D
## Oakhaven Base Hub — stations open panels / start mission.


@onready var player: CharacterBody3D = $Player
@onready var prompt: CanvasLayer = $UI/InteractionPrompt
@onready var workshop: CanvasLayer = $UI/WorkshopUI
@onready var brief_panel: PanelContainer = $UI/BriefPanel
@onready var brief_body: Label = $UI/BriefPanel/Margin/VBox/Body
@onready var brief_map: TextureRect = $UI/BriefPanel/Margin/VBox/MapArt
@onready var brief_title: Label = $UI/BriefPanel/Margin/VBox/Title
@onready var director_check: CheckButton = $UI/BriefPanel/Margin/VBox/DirectorToggle
@onready var pred_option: OptionButton = $UI/BriefPanel/Margin/VBox/Predictability
@onready var start_mission_btn: Button = $UI/BriefPanel/Margin/VBox/StartMission
@onready var close_brief_btn: Button = $UI/BriefPanel/Margin/VBox/Close
@onready var status_toast: Label = $UI/StatusToast


func _ready() -> void:
	add_to_group("base_hub")
	brief_panel.visible = false
	ArtCatalog.apply_parchment_panel(brief_panel)
	ArtCatalog.style_ink_label(brief_title, 22)
	ArtCatalog.style_ink_label(brief_body, 15)
	ArtCatalog.style_button(start_mission_btn)
	ArtCatalog.style_button(close_brief_btn)
	var map_tex := ArtCatalog.texture(ArtCatalog.WORLD_MAP)
	if map_tex:
		brief_map.texture = map_tex
	var interaction: InteractionController = player.get_node("InteractionController")
	interaction.prompt_changed.connect(func(t: String): prompt.set_prompt(t))
	start_mission_btn.pressed.connect(_start_mission)
	close_brief_btn.pressed.connect(_close_brief)
	pred_option.clear()
	pred_option.add_item("Predictability: Balanced", GameState.Predictability.BALANCED)
	pred_option.add_item("Predictability: High", GameState.Predictability.HIGH)
	pred_option.add_item("Predictability: Unpredictable", GameState.Predictability.UNPREDICTABLE)
	pred_option.select(0)
	director_check.button_pressed = GameState.director_enabled
	status_toast.text = "Oakhaven field post — visit Workshop, Map Room, then Command to deploy."


func open_station(station_id: String, _by: Node3D) -> void:
	match station_id:
		"workshop", "locker":
			workshop.open()
		"map", "command":
			_open_brief()
		"recon":
			_toast("Recon: Ironpeak passes clear. Eastern track unmarked.")
			GameState.intel += 0
		"comms":
			_toast("Comms: Highwatch standing by. No new traffic.")
		"archive":
			_toast("Archive: Kingsroad crossing last surveyed two seasons ago.")
		_:
			_toast("Station: %s" % station_id)


func _open_brief() -> void:
	brief_body.text = "SUPPLY LINE\n\nObjective: Reach Highwatch Hold along the Kingsroad.\nKnown risk: Oakhaven River crossing may be contested or damaged.\n\nCraft optional kits in the Workshop. Equip up to 2. Kits add ways to solve pivots — they are never required.\n\nFailed plans create information, not punishment."
	brief_panel.visible = true
	GameState.input_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _close_brief() -> void:
	brief_panel.visible = false
	GameState.input_locked = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _start_mission() -> void:
	GameState.director_enabled = director_check.button_pressed
	GameState.predictability = pred_option.get_selected_id() as GameState.Predictability
	GameState.input_locked = false
	SupplyLineMission.begin()
	SceneRouter.to_supply_line()


func _toast(text: String) -> void:
	status_toast.text = text
