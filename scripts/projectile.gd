extends Area2D

@export_category('Projectile Variables')
@export var PROJECTILE_SPEED : float = 1500
@export var parent : CharacterBody2D 
@export var duration : int = 60
@export var damage = 3

var frame = 0
var direction = Vector2(1, 0)
var player_list = []

func _ready():
	player_list.append(parent)
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame += floor(delta * 60)
	if frame >= duration:
		queue_free()
		
	var motion = direction.normalized() * PROJECTILE_SPEED
	position += motion * delta
	rotation_degrees = direction.angle() * 180.0 / PI

func set_direction(new_direction: Vector2):
	direction = new_direction
	
func dir(x,y):
	direction = Vector2(x , y)

func _on_arrow_body_entered(body):
	if not(body in player_list):
		body.percentage += damage
		queue_free()
