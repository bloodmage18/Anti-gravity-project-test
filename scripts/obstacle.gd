extends Node2D

# Define the different modes available
enum Mode { MOVE_HORIZONTAL, MOVE_VERTICAL, ROTATE_RIGHT, ROTATE_LEFT, ROTATE_BOTH }

# Export variables to customize obstacle behavior from the editor
@export var mode: Mode = Mode.MOVE_HORIZONTAL
@export var speed: float = 100.0 # Speed of movement or rotation
@export var rotation_speed: float = 90.0 # Degrees per second

# Variables for movement direction
var direction: Vector2 = Vector2(1, 0) # Default to moving right

func _ready():
	# Initialize any settings here if needed
	if mode == Mode.MOVE_VERTICAL:
		direction = Vector2(0, 1) # Set direction to move downwards initially
	elif mode == Mode.MOVE_HORIZONTAL:
		direction = Vector2(1, 0) # Set direction to move right initially

func _process(delta):
	match mode:
		Mode.MOVE_HORIZONTAL:
			move_obstacle(delta)
		Mode.MOVE_VERTICAL:
			move_obstacle(delta)
		Mode.ROTATE_RIGHT:
			rotate_obstacle_right(delta)
		Mode.ROTATE_LEFT:
			rotate_obstacle_left(delta)
		Mode.ROTATE_BOTH:
			rotate_obstacle_both(delta)

func move_obstacle(delta):
	# Move the obstacle in the specified direction
	position += direction * speed * delta

	# Check for collision or bounds (add your own bounds logic)
	if position.x > 500 or position.x < 0: # Example boundary check
		direction.x *= -1 # Reverse direction
	if position.y > 500 or position.y < 0: # Example boundary check
		direction.y *= -1 # Reverse direction

func rotate_obstacle_right(delta):
	# Rotate the obstacle right
	rotation_degrees += rotation_speed * delta

func rotate_obstacle_left(delta):
	# Rotate the obstacle left
	rotation_degrees -= rotation_speed * delta

func rotate_obstacle_both(delta):
	# Rotate in both directions alternatively
	rotation_degrees += rotation_speed * delta if randf() > 0.5 else -rotation_speed * delta
