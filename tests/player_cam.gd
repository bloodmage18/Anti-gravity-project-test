extends Camera2D

@export var player:Bob
@export var speed = 5

func _ready():
	player = $"../bob"

func _physics_process(delta):
	position = player.position
	#position = move_toward(position , player.global_transform.origin , speed * delta )#lerp(global_transform.origin , player.global_transform.origin , speed * delta)

