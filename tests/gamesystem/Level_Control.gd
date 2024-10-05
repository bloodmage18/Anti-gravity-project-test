extends Control

# References to the markers (sections) in the main game scene
@export var level_markers: Array[NodePath] = []
@onready var start_position : Vector2 = Vector2.ZERO

# Signal to notify the main scene which level was selected
signal level_selected(start_position: Vector2 , index : int)

func _ready():
	# This function will run when the level selection UI is ready.
	# You can populate buttons or UI elements here based on levels (sections).
	# Example: Assuming you have 6 buttons (one for each level/section)
	for i in range(6):
		var button = Button.new()
		button.text = "Start at Level %d" % (i + 1)
		button.connect("pressed", _on_level_button_pressed.bind(i))
		$VBoxContainer.add_child(button)
		print("ready")

func _on_level_button_pressed(level_index: int):
	# Get the position of the selected level marker
	var marker = get_node(level_markers[level_index])
	start_position = marker.global_transform.origin
	
	# Emit the signal with the selected start position
	emit_signal("level_selected", start_position , level_index)
	#get_parent()._on_level_selected(start_position)
	print("sending signal")
	
	# Close the level selection UI after the selection
	queue_free()
