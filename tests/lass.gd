extends CharacterBody2D
 
const SPEED: float = 350
const GRAVITY: float = 450
const JUMP: float = -400
var air_time = 0
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
	falling,
	on_floor,
	in_air
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
	
func _process(delta):
	move_state(delta)

func _physics_process(delta: float) -> void:
	get_input()
	
	snap_label.text = "snap : " + str(floor_snap_length)
	
	# Detect surface collisions
	colliding_ray = null
	if floor_detector.is_colliding():
		colliding_ray = floor_detector
	elif up_detector.is_colliding():
		colliding_ray = up_detector
	
	# Gravity system
	gravity_dir = -up_direction

	if floor_detector.is_colliding():
		var normal = floor_detector.get_collision_normal()
		up_direction = normal
		var angle = Vector2.UP.angle_to(normal)
		rotation = angle
		velocity = raw_velocity.rotated(angle)
	elif up_detector.is_colliding():
		raw_velocity.y = 0.0
		var normal = up_detector.get_collision_normal()
		up_direction = normal
		var angle = Vector2.UP.angle_to(normal)
		rotation = angle
	
		
	move_and_slide()
	
func jump():
	raw_velocity.y = JUMP
	is_jumping = true
	set_floor_snap_length(0.0)  # Disable snap when jumping
	pass
	
func move_state(delta):
	match states:
		state_machine.idle:
			rot_label.text = "state : idle"
			
			if Input.is_action_just_pressed("jump"):
				jump()
				print("moving to jump")
				states = state_machine.jumping
			
			if raw_velocity.x != 0.0 :
				print("moving to running")
				states = state_machine.running
				
			if !is_on_floor() and !colliding_ray:
				print("in air")
				#states = state_machine.in_air
				states = state_machine.falling
				
			
		state_machine.running:
			rot_label.text = "state : running"
			
			if raw_velocity.x == 0.0 :
				print("moving to idle")
				states = state_machine.idle
				
			else:
				snap = Vector2.DOWN * 128 if !is_jumping else Vector2.ZERO
				set_floor_snap_length(snap.y)
				velocity = (raw_velocity.x * transform.x) + (raw_velocity.y * transform.y)
				
				if Input.is_action_just_pressed("jump"):
					jump()
					states = state_machine.jumping
				
		state_machine.jumping:
			rot_label.text = "state : jumping"
			air_time += delta
			
			if colliding_ray:
				print("movinf to idling")
				states = state_machine.idle
				
			if air_time > AIR_TIME_THRESHOLD:
				#velocity = raw_velocity
				air_time = 0.0
				is_jumping = false
				velocity = velocity.rotated(-angle)
				states = state_machine.falling
			else:
				colliding_ray = null
				# Still use transformed velocity for parkour jumps
				velocity = (raw_velocity.x * transform.x) + (raw_velocity.y * transform.y)
				
			pass
		state_machine.falling:
			rot_label.text = "state : falling"
			
			if colliding_ray and is_on_floor() || is_on_ceiling():
				print("landed")
				states = state_machine.on_floor
				raw_velocity += gravity_dir * GRAVITY * delta
			else:
				states = state_machine.in_air
			
		state_machine.on_floor:
			rot_label.text = "state : on floor"
			
			if is_on_floor():
				print("moving to idle")
				states = state_machine.idle
			else:
				velocity = raw_velocity
				
		state_machine.in_air:
			rot_label.text = "state : in air"
			
			if colliding_ray:
				print("landed")
				states = state_machine.on_floor
			else:
				air_time = 0.0
				raw_velocity += Vector2.DOWN * GRAVITY * delta
				velocity = velocity.rotated(-angle)
				velocity = raw_velocity
				states = state_machine.falling
			
