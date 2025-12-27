extends CharacterBody2D

@export var speed = 1200 / 4
@export var jump_speed = -1800 / 2
@export var gravity = 4000 / 4
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0, 1.0) var acceleration = 0.25

@onready var floor_detector: RayCast2D = $Raycasts/GroundCast as RayCast2D
@onready var up_detector: RayCast2D = $Raycasts/DirectCast as RayCast2D

@onready var rot_label = $Control/rot
@onready var snap_label = $Control/snap

var colliding_ray = null
var gravity_dir : Vector2
var raw_velocity : Vector2
var angle = 0.0
var air_time = 0.0
var air_time_limit = 0.5

func _physics_process(delta):
	
	# Detect surface collisions and update rotation FIRST
	_omnidirectional_movement(delta)
	
	colliding_ray = null
	if floor_detector.is_colliding():
		colliding_ray = floor_detector
	elif up_detector.is_colliding():
		colliding_ray = up_detector
	
	# Gravity system
	gravity_dir = -up_direction
	
	# Apply gravity
	if !is_on_floor():
		# in air - apply gravity
		raw_velocity.y += gravity * delta
		# in air - count air time
		air_time += delta
	else:
		# On floor - reset vertical velocity
		raw_velocity.y = 0.0
		# on floor - reset air time
		air_time = 0.0
		
	
	
	# Get input (world space)
	var input_x = Input.get_axis("left", "right")
	
	# Apply acceleration/friction to horizontal velocity
	if input_x != 0:
		raw_velocity.x = lerp(raw_velocity.x, input_x * speed, acceleration)    
	else:
		raw_velocity.x = lerp(raw_velocity.x, 0.0, friction)
		
	if air_time > air_time_limit:
		# in air - reset angle jump
		up_direction = Vector2.UP
		gravity_dir = Vector2.DOWN
		
		if input_x != 0:
			rotation = move_toward(rotation, 0, delta * 5.0)
		else:
			rotation = move_toward(rotation , -rotation , delta * 1.2)
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		raw_velocity.y = jump_speed
		set_floor_snap_length(0.0)
	
	# Apply snap when on surface
	if is_on_floor() and Input.get_axis("left", "right") != 0:
		set_floor_snap_length(128.0)
	else:
		set_floor_snap_length(0.0)
	
	# Transform velocity to local space (relative to surface rotation)
	velocity = (raw_velocity.x * transform.x) + (raw_velocity.y * transform.y)
	
	move_and_slide()

func _omnidirectional_movement(delta):
	if floor_detector.is_colliding():
		var normal = floor_detector.get_collision_normal()
		up_direction = normal
		angle = Vector2.UP.angle_to(normal)
		rotation = angle
		#velocity = raw_velocity.rotated(angle)
	elif up_detector.is_colliding():
		var normal = up_detector.get_collision_normal()
		up_direction = normal
		angle = Vector2.UP.angle_to(normal)
		rotation = angle
