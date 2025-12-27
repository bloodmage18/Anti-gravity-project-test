extends CharacterBody2D
 
const SPEED: float = 350
const GRAVITY: float = 450
const JUMP: float = -400
var air_time = 0.0
var AIR_TIME_THRESHOLD = 0.2

var raw_velocity: Vector2
var gravity_dir: Vector2
var colliding_ray 

@export_category("states")
@export var is_falling : bool = false
@export var is_jumping : bool = false
@export var is_walking : bool = false
@export var is_in_air  : bool = false

enum state_machine{
	idle,
	running,
	jumping,
	falling
}
var states = state_machine.idle
 
@onready var floor_detector: RayCast2D = $Raycasts/GroundCast as RayCast2D
@onready var up_detector: RayCast2D = $Raycasts/DirectCast as RayCast2D

@onready var rot_label = $Control/rot
@onready var snap_label = $Control/snap

var snap : Vector2
var angle : float

func _ready():
	states = state_machine.idle

func get_input():
	raw_velocity.x = Input.get_axis("left", "right") * SPEED

func _physics_process(delta: float) -> void:
	get_input()
	
	# Detect surface collisions
	colliding_ray = null
	if floor_detector.is_colliding():
		colliding_ray = floor_detector
	elif up_detector.is_colliding():
		colliding_ray = up_detector
	
	# Gravity system
	gravity_dir = -up_direction
	
	# Count air time
	if !colliding_ray:
		air_time += delta
	else:
		air_time = 0.0
	
	# Reset to world gravity after threshold
	if air_time > AIR_TIME_THRESHOLD:
		up_direction = Vector2.UP
		rotation = move_toward(rotation, 0, delta * 5.0)
		gravity_dir = Vector2.DOWN
	
	# Apply gravity when in air
	if !colliding_ray:
		raw_velocity.y += GRAVITY * delta
	
	# Surface rotation - INSTANT stick with velocity correction
	if floor_detector.is_colliding():
		var normal = floor_detector.get_collision_normal()
		
		# Cancel velocity component moving away from surface
		var velocity_towards_surface = raw_velocity.dot(normal)
		if velocity_towards_surface < 0:  # Moving away from surface
			raw_velocity -= normal * velocity_towards_surface  # Cancel that component
		
		up_direction = normal
		angle = Vector2.UP.angle_to(normal)
		rotation = angle
		
		velocity = raw_velocity.rotated(angle)
	elif up_detector.is_colliding():
		var normal = up_detector.get_collision_normal()
		
		# Cancel velocity component moving away from surface
		var velocity_towards_surface = raw_velocity.dot(normal)
		if velocity_towards_surface < 0:  # Moving away from surface
			raw_velocity -= normal * velocity_towards_surface  # Cancel that component
		
		up_direction = normal
		angle = Vector2.UP.angle_to(normal)
		rotation = angle
	
	# Move physics
	move_and_slide()
	
	# Update state machine AFTER physics
	move_state(delta)
	
	# Update UI
	snap_label.text = "snap : " + str(floor_snap_length)

func jump():
	raw_velocity.y = JUMP
	is_jumping = true
	set_floor_snap_length(0.0)

func move_state(delta):
	match states:
		state_machine.idle:
			rot_label.text = "state : idle"
			
			if Input.is_action_just_pressed("jump"):
				jump()
				states = state_machine.jumping
			elif raw_velocity.x != 0.0:
				states = state_machine.running
			elif !is_on_floor() and !colliding_ray:
				states = state_machine.falling
			# Stay in idle
		
		state_machine.running:
			rot_label.text = "state : running"
			
			if Input.is_action_just_pressed("jump"):
				jump()
				states = state_machine.jumping
			elif raw_velocity.x == 0.0:
				states = state_machine.idle
			elif !colliding_ray:
				states = state_machine.falling
			else:
				# Apply snap when running on surface
				set_floor_snap_length(128.0)
				velocity = (raw_velocity.x * transform.x) + (raw_velocity.y * transform.y)
		
		state_machine.jumping:
			rot_label.text = "state : jumping"
			
			# Check for landing (instant stick)
			if colliding_ray:  # ← Added colliding_ray check
				is_jumping = false
				raw_velocity.y = 0.0  # ← Cancel vertical velocity on landing
				states = state_machine.idle
			# Transition to falling after threshold
			elif air_time > AIR_TIME_THRESHOLD:
				is_jumping = false
				states = state_machine.falling
			else:
				# Parkour jump - use transformed velocity
				velocity = (raw_velocity.x * transform.x) + (raw_velocity.y * transform.y)
		
		state_machine.falling:
			rot_label.text = "state : falling"
			
			# Check for landing
			if colliding_ray:  # ← Added colliding_ray check
				raw_velocity.y = 0.0  # ← Cancel vertical velocity on landing
				states = state_machine.idle
			else:
				# Use world-space velocity when falling
				velocity = raw_velocity
