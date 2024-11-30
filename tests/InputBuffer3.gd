extends Node

# Input buffer array
var input_buffer: Array[String] = []
const BUFFER_DURATION = .5  # Time in seconds each input stays in the buffer
const MAX_BUFFER_SIZE = 5   # Maximum number of inputs to store

# Define possible combos
var combos: Dictionary = {
	"J,J,J": "light_combo",
	"K,K,K": "bow_combo",
	"L,L,L": "heavy_combo",
	"J,K,L": "special_combo",  # Example combo pattern
	"J,J,K,K,L": "combo_chain"
}

# Timers for each input in the buffer
var input_timers: Array[float] = []

@onready var input_display_label = $InputDisplayLabel
@onready var attack_display_label = $AttackDisplayLabel

# Called every frame to update input and print buffer
func _process(delta: float) -> void:
	#handle_input()
	update_buffer_timers(delta)
	print_current_buffer()
	update_input_display()
	
func _physics_process(delta):
	handle_input()

# Function to handle input detection
func handle_input() -> void:
	var input_detected = ""

	if Input.is_action_just_pressed("move_up"):
		input_detected = "W"
	elif Input.is_action_just_pressed("move_left"):
		input_detected = "A"
	elif Input.is_action_just_pressed("move_right"):
		input_detected = "D"
	elif Input.is_action_just_pressed("move_down"):
		input_detected = "S"
	elif Input.is_action_just_pressed("attack_light"):
		input_detected = "J"
	elif Input.is_action_just_pressed("attack_bow"):
		input_detected = "K"
	elif Input.is_action_just_pressed("attack_heavy"):
		input_detected = "L"

	if input_detected != "":
		register_input(input_detected)

# Register input and manage buffer
func register_input(input_event: String) -> void:
	input_buffer.append(input_event)
	input_timers.append(BUFFER_DURATION)

	# Ensure the buffer doesn't exceed the max size
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
			trigger_attack("Executing Light Combo!")
			# Insert light combo logic
		"bow_combo":
			print("Executing Bow Combo!")
			trigger_attack("Executing Bow Combo!")
			# Insert bow combo logic
		"heavy_combo":
			print("Executing Heavy Combo!")
			trigger_attack("Executing Heavy Combo!")
			# Insert heavy combo logic
		"special_combo":
			print("Executing Special Combo!")
			trigger_attack("Executing Special Combo!")
			# Insert special move logic
		"combo_chain":
			print("combo chain : reset knockback")
			trigger_attack("combo chain")


# Update buffer timers and remove expired inputs
func update_buffer_timers(delta: float) -> void:
	for i in range(input_timers.size() - 1, -1, -1 ):
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

# Update the input display label
func update_input_display() -> void:
	if input_buffer.size() > 0:
		input_display_label.text = "[ " + ", ".join(input_buffer)
	else:
		input_display_label.text = " empty"#  "Input Buffer is empty."

# Display triggered attacks
func trigger_attack(attack_type: String) -> void:
	attack_display_label.text = attack_type #"Attack Triggered: " + attack_type
	# Optionally clear the attack label after a short delay
	await get_tree().create_timer(1).timeout
	attack_display_label.text = ""
