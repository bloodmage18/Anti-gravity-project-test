extends Area2D

@export_category('Projectile Variables')
@export var PROJECTILE_SPEED : float = 1500
@export var parent : CharacterBody2D 
@export var duration : int = 60
@export var damage = 3

var frame = 0
var dir_x = 1
var dir_y = 0
var player_list = []

func _ready():
	player_list.append(parent)
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame += floor(delta * 60)
	if frame >= duration:
		queue_free()
	var motion = (Vector2(dir_x,dir_y)).normalized() * PROJECTILE_SPEED
	set_position(get_position() + motion * delta)
	
	set_rotation_degrees(rad_to_deg(Vector2(dir_x,dir_y).angle()))

func dir(directionx , directiony):
	dir_x = directionx
	dir_y = directiony

func _on_arrow_body_entered(body):
	if not(body in player_list):
		body.percentage += damage
		queue_free()
