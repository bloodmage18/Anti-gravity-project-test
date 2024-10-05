extends Node

# Declare variables
@export var time_limit: float = 60.0  # Initial timer value in seconds
@export var flood_speed: float = 10.0  # Speed at which the flood rises
@export var zone_timer_reduction: float = 0.5  # How much the timer is reduced in zones
@export var level_markers: Array[NodePath] = []  # Paths to the level markers in the scene

var startgame : bool = false
var timer: float
var is_in_slow_zone: bool = false

# References to the player, flood, and the timer label
@onready var player = $player/bob
@onready var flood = $water
@onready var timer_label = get_node("CanvasLayer/Level_Control")#$"CanvasLayer/Control/VBoxContainer/TimerLabel"
@onready var game_label = $"CanvasLayer/Game_control/VBoxContainer/HBoxContainer/Game Message"
@onready var building_area :Area2D = $World/Node2D/BuildingArea
@onready var level_selector : Control = $CanvasLayer/Level_Control
@onready var game_controller : Control = $CanvasLayer/Game_control
@onready var home_bttn : TextureButton = get_node("CanvasLayer/Game_control/VBoxContainer/HBoxContainer/Home")
@onready var retry_bttn = get_node("CanvasLayer/Game_control/VBoxContainer/HBoxContainer/Retry")


func _ready():
	startgame = false
	 # Start with the level selector UI
	level_selector.connect("level_selected", _on_level_selected)
	# set timer
	timer = time_limit
	#flood.position.y = player.position.y - 2000#$World.get_viewport_rect().size.y  # Start flood at the bottom
	# play zone anim
	$World/Node2D/BuildingArea/AnimatedSprite2D.play("loop")
	$CanvasLayer/Game_control/VBoxContainer/HBoxContainer.hide()
	#Engine.set_time_scale(3)
	
func _process(delta):
	
	if startgame:
		update_timer(delta)
		move_flood(delta)
	
	check_game_over()

func update_timer(delta):
	if is_in_slow_zone:
		timer -= delta * zone_timer_reduction  # Slow down the timer in certain zones
	else:
		timer -= delta  # Normal timer countdown
	$CanvasLayer/Game_control/VBoxContainer/TimerLabel.text =  "Time: %.1f" % max(timer, 0)  # Update timer label

func move_flood(delta):
	# Move the flood upwards towards the player
	flood.position.y -= flood_speed * delta
	
func start_game():
	startgame = true
	game_controller.connect("home" , _on_home_bttn_pressed)
	game_controller.connect("retry" , _on_retry_bttn_pressed)

func check_game_over():
	if timer <= 0 :
		game_over("Game Over! You Run Out of Time.")
		print("plyer : " , player.position)
		print("flood : " , $water.position)
		startgame = false
	else:
		if building_area.get_overlapping_bodies():   #has_node(player):
			game_over("Congratulations! You reached the building.")
			
	if flood.position.y <= player.position.y:
		game_over("Game Over! You were caught by the flood.")
		print("plyer : " , player.position)
		print("flood : " , $water.position)
		startgame = false

func game_over(message: String):
	get_tree().paused = true
	game_label.text = message
	$CanvasLayer/Game_control.show()
	$CanvasLayer/Game_control/VBoxContainer/HBoxContainer.show()

func _on_level_selected(start_position: Vector2 , level_index: int):
	# Set the player's start position based on the selected level
	player.position = start_position
	timer = time_limit * (level_index+1)
	flood_speed = (flood_speed/2) * (level_index+1)
	print("time : " , timer , " - flood_speed : " , flood_speed)
	start_game()

func _on_home_bttn_pressed():
	await get_tree().create_timer(2).timeout
	Globals.load_screen_to_scene(Globals.main_menu)
	pass
	
func _on_retry_bttn_pressed():
	await get_tree().create_timer(2).timeout
	$CanvasLayer.queue_free()
	get_tree().reload_current_scene()
