extends Node2D

# Reference to input buffer singleton
@onready var input_buffer = $InputBuffer

func _process(delta):
	input_buffer.handle_input()
	# Call movement and combat handling functions here
	#handle_movement()
	#handle_combat()
