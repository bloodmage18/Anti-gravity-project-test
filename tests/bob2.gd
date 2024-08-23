extends CharacterBody2D
class_name Bob

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var projectile = preload("res://tests/projectile.tscn")
@onready var gun_pos : Marker2D = $Node2D/Marker2D
@onready var attack : Node = $AttacksFunctions
@onready var states = $State_Label
@onready var frame_counter = $Frame_Counter
@onready var anim : AnimationPlayer = $Node2D/Sprite/AnimationPlayer
@onready var Sprite = $'Node2D/Sprite'
@onready var body : Node2D = $Node2D

@onready var GroundL : RayCast2D  = $Raycasts/GroundL
@onready var GroundR : RayCast2D = $Raycasts/GroundR
@onready var Ledge_Grab_F : RayCast2D = $Raycasts/Ledge_Grab_F
@onready var Ledge_Grab_B : RayCast2D = $Raycasts/Ledge_Grab_R
@onready var Platform_Cast_D : RayCast2D = $Raycasts/Platform_Cast_Down
@onready var Platform_Cast_U : RayCast2D = $Raycasts/Platform_Cast_UP


#Ground Variables
var dash_duration = 10

#Air Variables
var landing_frames = 0
var lag_frames = 0
var jump_squat = 3
var fastfall = false
var roll_duration = 10

var RUNSPEED = 340
var DASHSPEED = 390
var WALKSPEED = 200
var GRAVITY = 1800
var JUMPFORCE = 500
var MAX_JUMPFORCE = 800
var DOUBLEJUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 900
var MAXFALLSPEED = 900
var TRACTION = 40
var ROLL_DISTANCE = 350
var air_dodge_speed = 500
var UP_B_LAUNCHSPEED = 700

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var id = 1
var frame = 0


func create_Projectile2(dir_x, dir_y, point):
	# Instance projectile
	var projectile_instance = projectile.instantiate() as Area2D
	projectile_instance.player_list.append(self)
	get_parent().add_child(projectile_instance)
	# Apply the player's rotation to the direction vector
	var direction_vector = Vector2(direction(), dir_y).rotated(self.rotation)
	point = point * direction()
	# Set projectile direction and position
	projectile_instance.dir(direction_vector.x, direction_vector.y)
	var global_point = gun_pos.get_global_position() + point.rotated(self.rotation)
	projectile_instance.set_global_position(global_point)
	
	return projectile_instance



func updateframes(delta):
	frame += 1

func _frame():
	frame = 0

func _ready():
	pass

func _physics_process(delta):
	_rotate()
	frame_counter.text = str(frame)
	pass

func direction():
	if Ledge_Grab_F.get_target_position().x > 0:
		return 1
	else:
		return -1
	
func play_animation(animation_name):
	anim.play(str(animation_name))

func turn(direction):
	var dir = 0
	if direction:
		dir = -1
	else:
		dir = 1
	Sprite.set_flip_h(direction)
	#Sprite.flip_h = direction
	
	Ledge_Grab_F.set_target_position(Vector2(dir*abs(Ledge_Grab_F.get_target_position().x),Ledge_Grab_F.get_target_position().y))
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.set_target_position(Vector2(-dir*abs(Ledge_Grab_F.get_target_position().x),Ledge_Grab_F.get_target_position().y))


## PLatform functions
func rotate_to_platform(platform_normal: Vector2):
	# Align player with platform normal
	var angle = platform_normal.angle()  # Get angle from normal
	rotation = angle  + deg_to_rad(90)# Rotate player to match platform
	
func adjust_movement_for_surface():
	# Rotate velocity to match platform orientation
	var rotation_matrix = Transform2D(rotation, Vector2.ZERO)
	velocity = rotation_matrix.basis_xform(velocity)
	
func calculate_jump_velocity():
	# Adjust jump velocity based on current orientation
	var jump_direction = -Vector2.UP.rotated(rotation)
	velocity = jump_direction * JUMPFORCE
	
func _rotate():
	if Platform_Cast_U.is_colliding():
		rotation = Platform_Cast_U.get_collision_normal().angle() + deg_to_rad(180)
		rotation = deg_to_rad(180)
	else:
		rotation = deg_to_rad(0)
		
	if Platform_Cast_D.is_colliding():
		var normal = Platform_Cast_D.get_collision_normal()
		rotation = normal.angle() + deg_to_rad(90)
	
func _attach_to_platform(delta):
	#var  move_direction = Vector2()
	#var normal = Platform_Cast_D.get_collision_normal()
	#var impulse = -normal * FALLINGSPEED
	#velocity.y += impulse.y * delta
	velocity.y += gravity * .5
	#print(velocity)
