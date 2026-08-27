extends Node3D
## Supply Line mission scene — walk Kingsroad into the destroyed bridge pivot.


@onready var player: CharacterBody3D = $Player
@onready var prompt: CanvasLayer = $UI/InteractionPrompt
@onready var builder: Node3D = $World
@onready var crossing_area: Area3D = $CrossingTrigger
@onready var highwatch_area: Area3D = $HighwatchTrigger

var _crossing_fired := false


func _ready() -> void:
	var interaction: InteractionController = player.get_node("InteractionController")
	interaction.prompt_changed.connect(func(t: String): prompt.set_prompt(t))
	crossing_area.body_entered.connect(_on_crossing_entered)
	highwatch_area.body_entered.connect(_on_highwatch_entered)
	GameState.pivot_closed.connect(_on_pivot_closed)
	if GameState.mission_id != SupplyLineMission.MISSION_ID:
		SupplyLineMission.begin()


func _on_crossing_entered(body: Node3D) -> void:
	if body != player:
		return
	if _crossing_fired:
		return
	_crossing_fired = true
	# World-first: player sees destroyed bridge before UI
	await get_tree().create_timer(0.35).timeout
	SupplyLineMission.on_arrive_crossing()


func _on_highwatch_entered(body: Node3D) -> void:
	if body != player:
		return
	if GameState.mission_status != GameState.MissionStatus.ACTIVE:
		return
	var can_pass := GameState.has_flag("crossing_open") or GameState.has_flag("bypass_crossing")
	if not can_pass:
		return
	var route := "direct"
	if GameState.has_flag("bridge_built"):
		route = "field-bridge"
	elif GameState.has_flag("crossing_repaired"):
		route = "repaired"
	elif GameState.has_flag("took_eastern"):
		route = "eastern"
	elif GameState.has_flag("discovered_ford"):
		route = "ford"
	elif GameState.has_flag("adapted_at_crossing"):
		route = "adapted"
	SupplyLineMission.finish_with_route(route)
	SceneRouter.to_after_action()


func _on_pivot_closed() -> void:
	if GameState.has_flag("crossing_open") or GameState.has_flag("bridge_built") or GameState.has_flag("crossing_repaired"):
		if builder.has_method("set_bridge_repaired"):
			builder.set_bridge_repaired(true)
