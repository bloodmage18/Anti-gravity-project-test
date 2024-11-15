extends Node

# Input buffer array
var input_buffer: Array[String] = []
const BUFFER_DURATION = 0.3  # Time in seconds each input stays in the buffer
const MAX_BUFFER_SIZE = 5    # Maximum number of inputs to store

# Timers for each input in the buffer
var input_timers: Array[float] = []

# Called every frame to update input and print buffer
func _process(delta: float) -> void:
	#handle_input()
	update_buffer_timers(delta)
	print_current_buffer()
	
func _physics_process(delta):
	handle_input()

# Function to handle input detection
func handle_input() -> void:
	var input_detected = ""

	if Input.is_action_just_pressed("move_up"):
		input_detected = "W (Up/Wall Run)"
	elif Input.is_action_just_pressed("move_left"):
		input_detected = "A (Left)"
	elif Input.is_action_just_pressed("move_down"):
		input_detected = "D (Down)"
	elif Input.is_action_just_pressed("move_crouch"):
		input_detected = "S (Crouch)"
	elif Input.is_action_just_pressed("attack_light"):
		input_detected = "J (Light Attack)"
	elif Input.is_action_just_pressed("attack_bow"):
		input_detected = "K (Bow Attack)"
	elif Input.is_action_just_pressed("attack_heavy"):
		input_detected = "L (Heavy Attack)"

	if input_detected != "":
		print("Input detected: " + input_detected)
		register_input(input_detected.split(" ")[0])  # Store only the key part (e.g., "J")

# Register input and manage buffer
func register_input(input_event: String) -> void:
	input_buffer.append(input_event)
	input_timers.append(BUFFER_DURATION)

	# Ensure the buffer doesn't exceed the max size
	if input_buffer.size() > MAX_BUFFER_SIZE:
		input_buffer.pop_front()
		input_timers.pop_front()

# Update buffer timers and remove expired inputs
func update_buffer_timers(delta: float) -> void:
	for i in range(input_timers.size() - 1, -1, -1):
		input_timers[i] -= delta
		if input_timers[i] <= 0:
			input_buffer.remove_at(i)
			input_timers.remove_at(i)

# Print the current buffer state
func print_current_buffer() -> void:
	if input_buffer.size() > 0:
		print("Current Input Buffer: ", input_buffer)
	else:
		#print("Input Buffer is empty.")
		pass
