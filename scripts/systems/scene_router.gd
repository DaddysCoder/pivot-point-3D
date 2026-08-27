extends Node
## Scene transitions for the vertical slice.


const SCENE_BOOT := "res://scenes/main/boot.tscn"
const SCENE_ONBOARDING := "res://scenes/main/onboarding.tscn"
const SCENE_CHARACTER_SELECT := "res://scenes/main/character_select.tscn"
const SCENE_BASE_HUB := "res://scenes/main/base_hub.tscn"
const SCENE_SUPPLY_LINE := "res://scenes/main/supply_line.tscn"
const SCENE_AFTER_ACTION := "res://scenes/main/after_action.tscn"


func go(path: String) -> void:
	get_tree().change_scene_to_file(path)


func to_onboarding() -> void:
	go(SCENE_ONBOARDING)


func to_character_select() -> void:
	go(SCENE_CHARACTER_SELECT)


func to_base_hub() -> void:
	go(SCENE_BASE_HUB)


func to_supply_line() -> void:
	go(SCENE_SUPPLY_LINE)


func to_after_action() -> void:
	go(SCENE_AFTER_ACTION)
