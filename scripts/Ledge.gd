extends Area2D

@export var ledge_side :String = "Left"
@onready var label = $Label
@onready var collision= $CollisionShape2D
var is_grabbed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if ledge_side == "Left":
		label.text = "Ledge_L"
	else:
		label.text = "Ledge_R"

func _on_body_exited(body):
	is_grabbed = false
