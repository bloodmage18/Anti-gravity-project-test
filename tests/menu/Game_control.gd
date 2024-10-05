extends Control
signal home
signal retry

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/Home.connect("pressed" , _home_bttn_pressed)
	$VBoxContainer/HBoxContainer/Retry.connect("pressed" , _retry_bttn_pressed)
	
func _home_bttn_pressed():
	emit_signal("home")
	print("emited home signal")
	
func _retry_bttn_pressed():
	emit_signal("retry")
	print("emited retry signal")
