extends Node

# Constants for the input buffer
const BUFFER_DURATION = 0.3  # Time in seconds an input stays in the buffer
const MAX_BUFFER_SIZE = 5    # Maximum number of inputs in the buffer

# Buffer to store recent inputs and their timers
var input_buffer: Array[String] = []
var input_timers: Array[float] = []

# Define possible combos
var combos: Dictionary = {
	"J,J,J": "light_combo",
	"K,K,K": "bow_combo",
	"L,L,L": "heavy_combo",
	"J,K,L": "special_combo"  # Example combo pattern
}

# Called every frame to update buffer timers
func _process(delta: float) -> void:
	for i in range(input_timers.size() - 1, -1, -1):
		input_timers[i] -= delta
		if input_timers[i] <= 0:
			input_buffer.remove_at(i)
			input_timers.remove_at(i)

# Register input into the buffer
func register_input(input_event: String) -> void:
	input_buffer.append(input_event)
	input_timers.append(BUFFER_DURATION)

	# Ensure buffer does not exceed max size
	if input_buffer.size() > MAX_BUFFER_SIZE:
		input_buffer.pop_front()
		input_timers.pop_front()

	# Check for combos in the buffer
	check_for_combos()

# Check if the current buffer matches any combo
func check_for_combos() -> void:
	var buffer_str = ""
	for input_event in input_buffer:
		buffer_str += input_event + ","
	
	# Remove the trailing comma
	if buffer_str.ends_with(","):
		buffer_str = buffer_str.rstrip(",")
		#buffer_str = buffer_str.strip_ending(",")
	
	if combos.has(buffer_str):
		execute_combo(combos[buffer_str])
		input_buffer.clear()  # Clear buffer after a combo is executed

# Execute a combo action
func execute_combo(combo_action: String) -> void:
	match combo_action:
		"light_combo":
			print("Executing Light Combo!")
			# Insert light combo logic
		"bow_combo":
			print("Executing Bow Combo!")
			# Insert bow combo logic
		"heavy_combo":
			print("Executing Heavy Combo!")
			# Insert heavy combo logic
		"special_combo":
			print("Executing Special Combo!")
			# Insert special move logic

# Function to handle input (called by the main character script)
func handle_input() -> void:
	if Input.is_action_just_pressed("attack_light"):
		register_input("J")
	elif Input.is_action_just_pressed("attack_bow"):
		register_input("K")
	elif Input.is_action_just_pressed("attack_heavy"):
		register_input("L")
