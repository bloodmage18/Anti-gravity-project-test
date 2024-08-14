extends CharacterBody2D
class_name Bob



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var states = $State_Label
@onready var frame_counter = $Frame_Counter
@onready var anim : AnimationPlayer = $Node2D/Sprite/AnimationPlayer
@onready var Sprite = $'Node2D/Sprite'

@onready var GroundL = $Raycasts/GroundL
@onready var GroundR = $Raycasts/GroundR


#Ground Variables
var dash_duration = 10

#Air Variables
var landing_frames = 0
var lag_frames = 0
var jump_squat = 3
var fastfall = false

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
func updateframes(delta):
	frame += 1
	
func _frame():
	frame = 0

func _physics_process(delta):
	frame_counter.text = str(frame)
	pass

	
func play_animation(animation_name):
	anim.play(str(animation_name))

func turn(direction):
	Sprite.flip_h = direction
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
#func turn_deprecated(direction):
##	var dir = 0
##	if direction:
##		dir = -1	
##	else:
##		dir = 1
##		Sprite.flip_h = false
	#pass
	
