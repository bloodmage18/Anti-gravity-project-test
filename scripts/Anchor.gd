extends Marker2D


@onready var cam = $Cam
@onready var bob = $"../bob"

var offsets := Vector2(10.0 , 20.0)
var offset_speed := 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target = bob.global_position
	var target_pox_x
	var target_pox_y
	target_pox_x = int(lerp(global_position.x , target.x + _dir(), 0.2))
	target_pox_y = int(lerp(global_position.y , target.y , 0.2))
	global_position = Vector2(target_pox_x , target_pox_y)
	
	var cam_offset_x
	var cam_offset_y
	cam_offset_x = int(lerp(global_position.x + _dir(), target.x , 0.2))
	cam_offset_y = int(lerp(global_position.y + _vel(), target.y , 0.4))
	cam.global_position.x = move_toward(cam.global_position.x , cam_offset_x , 0.6 )
	cam.global_position.y = move_toward(cam.global_position.y , cam_offset_y , 1.5)
	
func _dir():
	var input_dir = Input.get_axis("left","right")
	var dir = 150 * input_dir
	return dir

func _vel():
	var input_dir = Input.get_axis("up","down")
	var vel = floor(bob.velocity.normalized().y)
	# falling
	if bob.fastfall == true:
		vel = 200 * 1
		return vel
	# wall states
	elif Input.is_action_pressed("jump"):
		vel = 250 * -1
		return vel
	# pressing up
	elif input_dir == -1:
		vel = 200 * -1
		return vel
	# pressing down
	elif input_dir == 1:
		vel = 200 * 1
		return vel
	else:
		return vel
