extends Node
#
#@onready var player = $"../bob"
#@export var marker_point = 0
#@onready var markers = $"."
#var point 
## Called when the node enters the scene tree for the first time.
#func _ready():
	#point = markers.get_children()
	#player.position = point[marker_point].position
#
#func _input(event):
	#if Input.is_action_just_pressed("ui_left"):
		#if marker_point == 0 :
			#pass
		#else:
			#marker_point -= 1
			#player.position = point[marker_point].position
			#
	#if Input.is_action_just_pressed("ui_right"):
		#if marker_point == 6 :
			#pass
		#else:
			#marker_point += 1
			#player.position = point[marker_point].position
	#
