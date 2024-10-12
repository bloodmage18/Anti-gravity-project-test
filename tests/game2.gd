extends Node

# Game States
enum GameState { MENU, PLAYING, GAME_OVER }

# Declare variables
@export var time_limit: float = 60.0  # Initial timer value in seconds
@export var flood_speed: float = 10.0  # Speed at which the flood rises
@export var zone_timer_reduction: float = 0.5  # How much the timer is reduced in zones
@export var level_markers: Array[NodePath] = []  # Paths to the level markers in the scene

var timer: float
var is_in_slow_zone: bool = false
var startgame: bool = false
var game_state: GameState = GameState.MENU  # Initial state is MENU

# References to the player, flood, and the timer label
@onready var player = $player/bob
@onready var flood = $water
@onready var timer_label = get_node("CanvasLayer/Level_Control")  # Timer label node
@onready var game_label = $"CanvasLayer/Game_control/VBoxContainer/HBoxContainer/Game Message"
@onready var building_area: Area2D = $World/Node2D/BuildingArea
@onready var level_selector: Control = $CanvasLayer/Level_Control
@onready var game_controller: Control = $CanvasLayer/Game_control
@onready var home_bttn: TextureButton = get_node("CanvasLayer/Game_control/VBoxContainer/HBoxContainer/Home")
@onready var retry_bttn = get_node("CanvasLayer/Game_control/VBoxContainer/HBoxContainer/Retry")
@onready var camera = $player/Camera2D

func _ready():
	# Initialize game to MENU state
	_set_game_state(GameState.MENU)
	# Hide game controls initially
	$CanvasLayer/Game_control/VBoxContainer/HBoxContainer.hide()
	#game_controller.hide()
	
	# Connect signals for the buttons
	level_selector.connect("level_selected", _on_level_selected)
	home_bttn.connect("pressed", _on_home_bttn_pressed)
	retry_bttn.connect("pressed", _on_retry_bttn_pressed)
	
	# Set initial player position and flood position
	timer = time_limit
	flood.position.y = player.position.y - 2000  # Initial flood position

	# Play zone animation
	$World/Node2D/BuildingArea/AnimatedSprite2D.play("loop")

func _process(delta):
	if game_state == GameState.PLAYING:
		# Update game mechanics only during gameplay
		update_timer(delta)
		move_flood(delta)
		check_game_over()

# Game state management
func _set_game_state(new_state: GameState):
	game_state = new_state
	
	if game_state == GameState.MENU:
		# Reset positions for player, flood, and camera when in menu
		#camera.position = player.position  # Reset camera position
		#game_controller.hide()
		level_selector.show()
		get_tree().paused = false  # Unpause the game
	
	elif game_state == GameState.PLAYING:
		# Hide menu and start gameplay
		level_selector.hide()
		#game_controller.hide()
		startgame = true
		get_tree().paused = false
	
	elif game_state == GameState.GAME_OVER:
		# Pause the game and show game over controls
		startgame = false
		get_tree().paused = true
		game_controller.show()
		$CanvasLayer/Game_control/VBoxContainer/HBoxContainer.show()

# Handle timer logic
func update_timer(delta):
	if is_in_slow_zone:
		timer -= delta * zone_timer_reduction
	else:
		timer -= delta
	
	# Update timer label
	$CanvasLayer/Game_control/VBoxContainer/TimerLabel.text = "Time: %.1f" % max(timer, 0)

# Move flood upwards
func move_flood(delta):
	flood.position.y -= flood_speed * delta

# Start the game
func start_game():
	_set_game_state(GameState.PLAYING)

# Check if game over conditions are met
func check_game_over():
	if timer <= 0:
		game_over("Game Over! You ran out of time.")
	elif flood.position.y <= player.position.y:
		game_over("Game Over! You were caught by the flood.")
	elif building_area.get_overlapping_bodies():
		game_over("Congratulations! You reached the building.")

# Handle game over state
func game_over(message: String):
	game_label.text = message
	_set_game_state(GameState.GAME_OVER)

# Handle level selection
func _on_level_selected(start_position: Vector2, level_index: int):
	# Set the player's start position based on the selected level
	player.position = start_position
	timer = time_limit * (level_index + 1)
	flood_speed = (flood_speed / 2) * (level_index + 1)
	flood.position.y = start_position.y + 900
	start_game()

# Handle "Home" button pressed - Return to main menu
func _on_home_bttn_pressed():
	# Delay and load main menu
	await get_tree().create_timer(1).timeout
	Globals.load_screen_to_scene(Globals.main_menu)

# Handle "Retry" button pressed - Restart the level
func _on_retry_bttn_pressed():
	# Delay and reload the current scene
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()
