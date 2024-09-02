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
	add_state('TURN')
	add_state('CROUCH')
	add_state('SLIDE')
	
	# platform states
	add_state('ROLL')
	add_state('PLATFORM_STAND')
	add_state('PLATFORM_DASH')
	add_state('PLATFORM_WALK')
	add_state('PLATFORM_RUN')
	add_state('PLATFORM_JUMP')
	
	# bow attacks
	add_state('BOW_GROUND')
	add_state('BOW_AIR')
	
	# Hand Attacks
	add_state('GROUND_ATTACK')
	add_state('PUNCH_1')
	add_state('PUNCH_2')
	add_state('PUNCH_3')
	add_state('KICK_1')
	add_state('KICK_2')
	
	call_deferred("set_state" , states.STAND)

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	parent.adjust_movement_for_surface()

func get_transition(delta):
	parent._rotate()
	parent.move_and_slide()

	if state_includes([ states.PLATFORM_RUN , states.PLATFORM_DASH , states.CROUCH , states.MOONWALK , states.PLATFORM_STAND]):
		if parent.Platform_Cast_D.is_colliding() and not LANDING():
			parent._attach_to_platform(delta)
		
	if LANDING() == true:
		parent._frame()
		return states.LANDING
		
	if FALLING() == true:
		return states.AIR
		
	if PLATFORM_COLLIDED() == true :
		parent._frame()
		return states.ROLL
	else:
		pass
		
	if Input.is_action_just_pressed("heavy") && SPECIAL() == true:
		parent._frame()
		return states.GROUND_ATTACK
		
	if Input.is_action_just_pressed("light") && SPECIAL() == true:
		parent._frame()
		return states.GROUND_ATTACK
		
	if Input.is_action_just_pressed("mid") && SPECIAL() == true:
		parent._frame()
		return states.BOW_GROUND
	
	if Input.is_action_just_pressed("E"):
		if state_includes([states.RUN ]):
			parent._frame()
			return states.SLIDE
			
	#if Input.is_action_just_pressed("Q"):
		#parent._frame()
			#return states.ROLL
	
	match state:
		
		states.STAND:
#			print("idle")
			if Input.get_action_strength("jump"):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.get_action_strength("down"):
				parent._frame()
				return states.CROUCH
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
			if _on_platform():
				return states.PLATFORM_STAND
			
		states.WALK:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down"):
				parent._frame()
				return states.CROUCH
			if Input.get_action_strength("left"):
				parent.velocity.x = -parent.WALKSPEED * Input.get_action_strength("left")
				parent.turn(true)
			elif Input.get_action_strength("right"):
				parent.velocity.x = parent.WALKSPEED * Input.get_action_strength("right")
				parent.turn(false)
			else:
				parent._frame()
				return states.STAND
			pass
			
		states.RUN:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down"):
				parent._frame()
				return states.CROUCH
			if Input.is_action_pressed("left"):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
				else:
					parent._frame()
					return states.TURN
			elif Input.is_action_pressed("right"):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
				else:
					parent._frame()
					return states.TURN
			else:
				parent._frame()
				return states.STAND
			
		states.DASH:
			if Input.is_action_pressed("jump"):
				parent._frame()
				return states.JUMP_SQUAT
			
			elif Input.is_action_pressed("left"):
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration + 1:
					if Input.is_action_just_pressed("down"):
						parent._frame()
						return states.MOONWALK
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent._frame()
					return states.RUN
				
			elif Input.is_action_pressed("right"):
				if parent.velocity.x < 0:
					parent._frame()
					parent.turn(false)
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration + 1:
					if Input.is_action_just_pressed("down"):
						parent._frame()
						return states.MOONWALK
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent._frame()
					return states.RUN
					
			else:
				if parent.frame >= parent.dash_duration+1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent._frame()
							return states.STAND
				
		states.MOONWALK:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				return states.JUMP_SQUAT
				
			elif Input.is_action_pressed("left") && parent.direction() == 1:
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x += -parent.AIR_ACCEL * Input.get_action_strength("left")
				parent.velocity.x = clamp(parent.velocity.x, -parent.DASHSPEED * 1.4 , parent.velocity.x)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent._frame()
					return states.STAND
					
			elif Input.is_action_pressed("right") && parent.direction() == -1:
				if parent.velocity.x < 0:
					parent._frame()
				parent.velocity.x += parent.AIR_ACCEL * Input.get_action_strength("right")
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x , parent.DASHSPEED )
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(true)
					return states.MOONWALK
				else:
					parent.turn(false)
					parent._frame()
					return states.STAND
			
			else:
				if parent.frame > parent.dash_duration - 1 :
					for state in states:
						if state != "JUMP_SQUAT":
							return states.STAND
		
		states.CROUCH:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down"):
				parent._frame()
				# move to platform stand state if on platform
				if _on_platform():
					return states.PLATFORM_STAND
				else:
					return states.STAND
			elif parent.velocity.x > 0:
				if parent.velocity.x > parent.RUNSPEED:
					parent.velocity.x += -(parent.TRACTION * 4)
					parent.velocity.x = clamp(parent.velocity.x , 0 , parent.velocity.x) 
				else:
					parent.velocity.x += -(parent.TRACTION / 2)
					parent.velocity.x = clamp(parent.velocity.x , 0 , parent.velocity.x) 
			elif parent.velocity.x < 0 :
				if abs(parent.velocity.x) > parent.RUNSPEED:
					parent.velocity.x += (parent.TRACTION * 4)
					parent.velocity.x = clamp(parent.velocity.x , parent.velocity.x , 0) 
				else:
					parent.velocity.x += (parent.TRACTION / 2)
					parent.velocity.x = clamp(parent.velocity.x , parent.velocity.x , 0) 
		
		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump"):
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
			
			if Input.is_action_just_pressed("mid"):
				parent._frame()
				return states.BOW_AIR
			
		states.SLIDE:
			if parent.frame >= parent.slide_duration+1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent._frame()
							return states.STAND
			
		states.ROLL:
			parent.velocity.y -= parent.JUMPFORCE * delta
			#parent.body.rotation = parent.Platform_Cast_U.get_collision_normal().angle() - PI/2
			
			if parent.frame >= parent.roll_duration:
				parent._frame()
				return states.AIR
			
			if _on_platform():
				parent.velocity = Vector2.ZERO
				parent._frame()
				return states.PLATFORM_STAND
			
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
					
					if _on_platform():
						return states.PLATFORM_STAND
					else:
						return states.STAND
				parent.lag_frames = 0
			
		states.TURN:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0 :#and not parent.Platform_Cast_D.is_colliding():
				parent.turn(true)
				#parent.turn(false)
				parent.velocity.x += -parent.TRACTION*2
				parent.velocity.x =  clamp(parent.velocity.x , 0 , parent.velocity.x)
			elif parent.velocity.x < 0 :#and not  parent.Platform_Cast_D.is_colliding():
				#parent.turn(true)
				parent.turn(false)
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x =  clamp(parent.velocity.x , parent.velocity.x , 0)
			else:
				if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
					parent._frame()
					return states.STAND
				else:
					parent._frame()
					return states.RUN
		
		
		#PLatform States 
		states.PLATFORM_STAND:
			
			if Input.get_action_strength("jump"):
				parent._frame()
				return states.PLATFORM_JUMP
			if Input.get_action_strength("down"):
				parent._frame()
				return states.CROUCH
			if Input.get_action_strength("left"):
				parent.velocity.x = parent.RUNSPEED
				parent._frame()
				parent.turn(true)
				return states.PLATFORM_DASH
			if Input.get_action_strength("right"):
				parent.velocity.x = -parent.RUNSPEED
				parent._frame()
				parent.turn(false)
				return states.PLATFORM_DASH
			if parent.velocity.x > 0 and state == states.PLATFORM_STAND:
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.PLATFORM_STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
				
			if parent.velocity.y > 0 and state == states.PLATFORM_STAND:
				parent.velocity.y += -parent.TRACTION*1
				parent.velocity.y = clamp(parent.velocity.y,0,parent.velocity.y)
			elif parent.velocity.y < 0 and state == states.PLATFORM_STAND:
				parent.velocity.y += parent.TRACTION*1
				parent.velocity.y = clamp(parent.velocity.y,parent.velocity.y,0)
				
			parent.velocity.x = 0 #Vector2.ZERO
			
		states.PLATFORM_WALK:
			pass
			
		states.PLATFORM_RUN:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				return states.PLATFORM_JUMP
			if Input.is_action_just_pressed("down"):
				parent._frame()
				return states.CROUCH
			if Input.is_action_pressed("left"):
				#if parent.velocity.x <= 0:
				parent.velocity.x = -parent.RUNSPEED
				parent.turn(true)
				#print(parent.velocity)
				#else:
					#parent._frame()
					#return states.TURN
			elif Input.is_action_pressed("right"):
				#if parent.velocity.x >= 0:
				parent.velocity.x = parent.RUNSPEED
				parent.turn(false)
				#print(parent.velocity)
				#else:
					#parent._frame()
					#return states.TURN
			else:
				parent._frame()
				return states.PLATFORM_STAND
			
		states.PLATFORM_JUMP:
			parent.calculate_jump_velocity()
			return states.JUMP_SQUAT
			
		states.PLATFORM_DASH:
			parent.velocity = Vector2.ZERO
			if Input.is_action_pressed("jump"):
				parent._frame()
				return states.PLATFORM_JUMP
			
			elif Input.is_action_pressed("left"):
				if parent.velocity.x > 0:
					parent._frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration + 1:
					parent.turn(true)
					#parent._frame()
					return states.PLATFORM_DASH
				else:
					parent.turn(false)
					parent._frame()
					return states.PLATFORM_RUN
				
			elif Input.is_action_pressed("right"):
				if parent.velocity.x < 0:
					parent._frame()
					parent.turn(false)
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration + 1:
					parent.turn(false)
					#parent._frame()
					return states.PLATFORM_DASH
				else:
					parent.turn(false)
					parent._frame()
					return states.PLATFORM_RUN
					
			else:
				if parent.frame >= parent.dash_duration+1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent._frame()
							return states.PLATFORM_STAND
			pass
		
		
		# Bow Attacks
		states.BOW_GROUND:
			
			if parent.frame <= 1:
				if parent.attack.projectile_cooldown == 1:
					parent.attack.projectile_cooldown =- 1
				if parent.attack.projectile_cooldown == 0:
					parent.attack.projectile_cooldown += 1
					parent._frame()
					parent.attack.BOW_GROUND()
			if parent.frame < 14:
				#if Input.is_action_just_pressed("light"):
				if Input.is_action_just_pressed("right_click"):
					parent._frame()
					return states.BOW_GROUND
					
			if parent.attack.BOW_GROUND() == true:
				if AIREAL() == true:
					return states.AIR
				else:
					if parent.frame == 14:
						parent._frame()
						if _on_platform():
							return states.PLATFORM_STAND
						else:
							return states.STAND
			else:
				if parent.velocity.x > 0:
					if parent.velocity.x >  parent.DASHSPEED:
						parent.velocity.x = parent.DASHSPEED
					parent.velocity.x = parent.velocity.x - parent.TRACTION * 2
					parent.velocity.x = clampi(parent.velocity.x , 0 , parent.velocity.x)
				elif parent.velocity.x < 0:
					if parent.velocity.x < -parent.DASHSPEED:
						parent.velocity.x = -parent.DASHSPEED
					parent.velocity.x = parent.velocity.x + parent.TRACTION * 2
					parent.velocity.x = clampi(parent.velocity.x , parent.velocity.x , 0)
			
		states.BOW_AIR:
			if AIREAL() == true:
				AIRMOVEMENT()
			
			if parent.frame <= 1:
				if parent.attack.projectile_cooldown == 1:
					parent.attack.projectile_cooldown =- 1
				if parent.attack.projectile_cooldown == 0:
					parent.attack.projectile_cooldown += 1
					parent._frame()
					parent.attack.BOW_AIR()
			if parent.frame < 14:
				if Input.is_action_just_pressed("mid"):
					parent.velocity = Vector2.ZERO
					parent._frame()
					return states.BOW_AIR
			if parent.attack.BOW_AIR() == true:
				if AIREAL() == true:
					return states.AIR
				else:
					if parent.frame == 14:
						parent._frame()
						if _on_platform():
							return states.PLATFORM_STAND
						else:
							return states.STAND
		
		
		# Hand Attacks
		states.GROUND_ATTACK:
			if Input.is_action_pressed("light"):
				parent._frame()
				return states.KICK_1
			if Input.is_action_pressed("heavy"):
				parent._frame()
				return states.PUNCH_1
		
		states.PUNCH_1:
			if parent.frame == 0:
				parent.attack.Punch_1()
			if parent.frame < 23:
				if Input.is_action_just_pressed("heavy"):
					parent._frame()
					return states.PUNCH_2
			if parent.attack.Punch_1() == true:
				parent._frame()
				return states.STAND
		
		states.PUNCH_2:
			if parent.frame == 0:
				parent.attack.Punch_2()
			if parent.frame < 25:
				if Input.is_action_just_pressed("heavy"):
					parent._frame()
					return states.PUNCH_3
			if parent.attack.Punch_2() == true:
				parent._frame()
				return states.STAND
		
		states.PUNCH_3:
			if parent.frame == 0:
				parent.attack.Punch_3()
			if parent.anim.is_playing() == false:
				parent._frame()
				return states.STAND
			if parent.attack.Punch_3() == true:
				# chain attacks
				parent._frame()
				return states.GROUND_ATTACK
		
		states.KICK_1:
			if parent.frame == 0:
				parent.attack.KICK_A()
			if parent.anim.is_playing() == false:
				parent._frame()
				return states.STAND
			else:
				if parent.frame < 14:
					if Input.is_action_just_pressed("light"):
						parent._frame()
						return states.KICK_2
		
		states.KICK_2:
			if parent.frame == 0:
				parent.attack.KICK_B()
				
			if parent.anim.is_playing() == false:
				parent._frame()
				return states.STAND
		
		
		
	if parent.frame == 100:
		parent._frame()


func enter_state(new_state, old_state):
	match state:
		states.STAND:
			parent.play_animation('idle')
			parent.states.text = str('STAND')
		states.DASH:
			parent.play_animation('dash')
			parent.states.text = str('DASH')
		states.MOONWALK:
			parent.play_animation('walk')
			parent.states.text = str('MOONWALK')
		states.LANDING:
			parent.play_animation('landing')
			parent.states.text = str('LANDING')
		states.TURN:
			parent.play_animation('turn')
			parent.states.text = str('TURN')
		states.RUN:
			parent.play_animation('run')
			parent.states.text = str('RUN')
		states.WALK:
			parent.play_animation('walk')
			parent.states.text = str('WALK')
		states.CROUCH:
			parent.play_animation('crouch')
			parent.states.text = str('CROUCH')
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
		states.SLIDE:
			parent.play_animation('slide')
			parent.states.text = str('SLIDE')
		states.ROLL:
			parent.play_animation('roll')
			parent.states.text = str('ROLL')
		states.PLATFORM_STAND:
			parent.play_animation('idle')
			parent.states.text = str('PLATFORM_STAND')
		states.PLATFORM_DASH:
			parent.play_animation('dash')
			parent.states.text = str('PLATFORM_DASH')
		states.PLATFORM_RUN:
			parent.play_animation('run')
			parent.states.text = str('PLATFORM_RUN')
		states.PLATFORM_JUMP:
			parent.play_animation('short_hop')
			parent.states.text = str('PLATFORM_JUMP')
			
		# weapon : BOW and ARROW
		states.BOW_GROUND:
			parent.play_animation('bow_g')
			parent.states.text = str('GROUND_BOW')
		states.BOW_AIR:
			parent.play_animation('bow_a')
			parent.states.text = str('AIR_BOW')
			
		# weapon : UNARMED
		states.GROUND_ATTACK:
			parent.states.text = str('GROUND_ATTACK')
		states.PUNCH_1:
			parent.play_animation('Punch_01')
			parent.states.text = str('PUNCH_1')
		states.PUNCH_2:
			parent.anim.queue('Punch_02')
			parent.states.text = str('PUNCH_2')
		states.PUNCH_3:
			parent.anim.queue("Punch_03")
			parent.states.text = str('PUNCH_3')
			
		states.KICK_1:
			parent.play_animation('kick_01')
			parent.states.text = str('KICK_1')
		states.KICK_2:
			parent.anim.queue('kick_02')
			parent.states.text = str('KICK_2')
			
		
func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false
	
func RESET_ROTAION():
	if state_includes([states.AIR]):
		parent._rotate()
	
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
	if state_includes([states.AIR , states.BOW_AIR]):
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
	if state_includes([states.STAND ,states.DASH,states.MOONWALK,states.RUN,states.CROUCH,states.WALK,states.PLATFORM_STAND ,states.PLATFORM_RUN, states.PLATFORM_DASH ]):# states.ROLL ]):
		if parent.GroundL.is_colliding() and parent.GroundR.is_colliding() :
			return false
		else:
			return true
	#if state_includes([states.ROLL]):
		#if parent.Platform_Cast_U.is_colliding():
			#return false
		#else:
			#return true
			
func PLATFORM_COLLIDED():
	if parent.Platform_Cast_U.is_colliding():
		return true
	else:
		return false
	
func _on_platform():
	if parent.Platform_Cast_D.is_colliding():
		return true
	else:
		return false

func SPECIAL():
	if state_includes([states.WALK ,states.STAND ,states.DASH , states.MOONWALK , states.CROUCH , states.PLATFORM_STAND , states.PLATFORM_DASH , states.PLATFORM_RUN]):
		return true
		
func TILT():
	if state_includes([states.WALK ,states.STAND ,states.DASH , states.MOONWALK , states.CROUCH]):
		return true
		
func AIREAL():
	if state_includes([states.AIR , states.BOW_AIR]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false
