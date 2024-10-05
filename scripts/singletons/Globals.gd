extends Node

const title_screen : String = "res://tests/title_screen.tscn"
const main_menu : String = "res://tests/main.tscn" 
const game_scene : String = "res://tests/game.tscn"
const loading_screen : String = "res://tests/loading_scene.tscn"


func load_screen_to_scene(target: String) -> void:
	var loading_screen_scene = preload(loading_screen).instantiate()
	loading_screen_scene.next_scene_path = target
	get_tree().current_scene.add_child(loading_screen_scene)

