extends Node2D

@onready var animation_player = $Animation_Player

func _input(_event):
	#await get_tree().create_timer(3).timeout
	if Input.is_anything_pressed():
		animation_player.play("fade_out")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		await get_tree().create_timer(1.5).timeout
		Globals.load_screen_to_scene(Globals.main_menu)
