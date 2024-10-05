extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Control/PanelContainer.hide()

func _input(_event):
	if Input.is_anything_pressed() && $CanvasLayer/Control/PanelContainer.visible == true:
		$CanvasLayer/Control/PanelContainer.hide()
		$CanvasLayer/Control/PanelContainer/AnimationPlayer.play("RESET")
		$CanvasLayer/Control/PanelContainer/AnimationPlayer.stop(true)
		
func _on_new_game_pressed():
	Globals.load_screen_to_scene(Globals.game_scene)


func _on_load_game_pressed():
	$CanvasLayer/Control/PanelContainer.show()
	$CanvasLayer/Control/PanelContainer/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(2).timeout
	$CanvasLayer/Control/PanelContainer/AnimationPlayer.play("fade_in")
	$CanvasLayer/Control/PanelContainer.hide()
	pass # Replace with function body.


func _on_multiplayer_pressed():
	$CanvasLayer/Control/PanelContainer.show()
	$CanvasLayer/Control/PanelContainer/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(2).timeout
	$CanvasLayer/Control/PanelContainer/AnimationPlayer.play("fade_in")
	$CanvasLayer/Control/PanelContainer.hide()
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit(3)
	pass # Replace with function body.
