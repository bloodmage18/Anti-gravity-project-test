extends StateMachine

@onready var parent : Bob = get_parent()


func _ready():
	add_state('STAND')
	add_state('WALK')
	add_state('RUN')
	add_state('DASH')
	add_state('MOONWALK')
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('AIR')
	add_state('LANDING')
	add_state('CROUCH')
	call_deferred("set_state" , states.STAND)

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)

func get_transition(delta):
	parent.move_and_slide()
	
	if LANDING() == true:
		parent._frame()
		return states.LANDING
	
	if FALLING() == true:
		return states.AIR
	
	
	match state:
		states.STAND:
#			print("idle")
			if Input.get_action_strength("Jump"):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.get_action_strength("left"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.DASH
			if Input.get_action_strength("right"):
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			
		states.WALK:
			pass
		states.RUN:
			pass
			
		states.DASH:
			if Input.is_action_pressed("left"):
				if parent.velocity.x > 0:
					parent._frame()
					parent.turn(true)
				parent.velocity.x = -parent.DASHSPEED
			elif Input.is_action_pressed("right"):
				if parent.velocity.x < 0:
					parent._frame()
					parent.turn(false)
				parent.velocity.x = parent.DASHSPEED
			else:
				if parent.frame >= parent.dash_duration+1:
					return states.STAND
				
		states.MOONWALK:
			pass
		
		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("Jump"):
					parent.velocity.x = lerp(parent.velocity.x , 0.0 , 0.08)
					parent._frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerp(parent.velocity.x , 0.0 , 0.08)
					parent._frame()
					return states.FULL_HOP
					
		states.SHORT_HOP:
			parent.velocity.y = -parent.JUMPFORCE
			parent._frame()
			return states.AIR
			
		states.FULL_HOP:
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent._frame()
			return states.AIR
			
		states.AIR:
			AIRMOVEMENT()
			
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames:
				if parent.frame == 1:
					pass
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x , 0 , parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x , parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump"):
#					print_debug("jumped")
					parent._frame()
					return states.JUMP_SQUAT
#					print_debug("moving to jump_squat")
			else:
				if Input.is_action_pressed("down"):
					parent.lag_frames = 0
					parent._frame()
					#parent.reset_jumps()
					return states.CROUCH
				else:
#					print_debug("broke my knees as i touched the ground")
					parent._frame()
					#parent.reset_jumps()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0
			

func enter_state(new_state, old_state):
	match state:
		states.STAND:
			parent.play_animation('idle')
			parent.states.text = str('STAND')
		states.DASH:
			parent.play_animation('dash')
			parent.states.text = str('DASH')
		states.JUMP_SQUAT:
			parent.play_animation('jump_squat')
			parent.states.text = str('JUMP_SQUAT')
		states.SHORT_HOP:
			parent.play_animation('short_hop')
			parent.states.text = str('SHORT_HOP')
		states.FULL_HOP:
			parent.play_animation('short_hop')
			parent.states.text = str('FULL_HOP')
		states.AIR:
			parent.play_animation('air')
			parent.states.text = str('AIR')
		states.LANDING:
			parent.play_animation('landing')
			parent.states.text = str('LANDING')
		states.RUN:
			parent.play_animation('run')
			parent.states.text = str('RUN')
		states.WALK:
			parent.play_animation('walk')
			parent.states.text = str('WALK')
		states.CROUCH:
			parent.play_animation('crouch')
			parent.states.text = str('CROUCH')
		

func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
	

func AIRMOVEMENT():
#	print_debug("i believe i can fly")
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
#	if Input.is_action_pressed("down_%s" & id) and parent.down_buffer == 1 and parent.velocity.y > -150 and not parent.fastfall :
	if Input.is_action_pressed("down") and parent.velocity.y > -150 and not parent.fastfall :
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		#parent.set_collision_mask_bit(2,false)
		parent.velocity.y = parent.MAXFALLSPEED
		
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left"):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right"):
				parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left"):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right"):
				parent.velocity.x += parent.AIR_ACCEL
			
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left"):
			parent.velocity.x += -parent.AIR_ACCEL
		if Input.is_action_pressed("right"):
			parent.velocity.x += parent.AIR_ACCEL
		
	if not Input.is_action_just_released("left") and not Input.is_action_pressed("right"):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL/5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL/5


func LANDING():
#	added the sprite y offset variable since the character the above body .y
	var sprite_y_offset = $"../Node2D/Sprite".global_transform.origin
	if state_includes([states.AIR]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y > 0 - sprite_y_offset.y:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
		elif (parent.GroundR.is_colliding()) and parent.velocity.y > 0 -  sprite_y_offset.y:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true

	
func FALLING():
	if state_includes([states.STAND ,states.DASH,states.MOONWALK,states.RUN,states.CROUCH,states.WALK ]):
		if parent.GroundL.is_colliding():# or parent.GroundR.is_colliding():
			return false
		else:
			return true
