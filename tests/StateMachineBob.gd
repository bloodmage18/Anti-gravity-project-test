extends StateMachine

@onready var parent : Bob = get_parent()


func _ready():
	add_state('IDLE')
	add_state('WALK')
	add_state('RUN')
	add_state('DASH')
	add_state('MOONWALK')
	add_state('AIREAL')
	add_state('LANDING')
	call_deferred("set_state" , states.IDLE)

func state_logic(delta):
	parent._physics_process(delta)

func get_transition(delta):
	parent.move_and_slide()
	
	
	match state:
		states.IDLE:
#			print("idle")
			pass
		states.WALK:
			pass
		states.RUN:
			pass
		states.DASH:
			pass
		states.MOONWALK:
			pass
	
	
	return null

func enter_state(new_state, old_state):
	match state:
		states.IDLE:
			parent.play_animation('idle')
			
	pass

func exit_state(old_state, new_state):
	pass


func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
