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
	add_state('AIR_DASH')
	add_state('LANDING')
	add_state('TURN')
	add_state('CROUCH')
	add_state('SLIDE')
	
	# ledge and wall statess
	add_state('LEDGE_CATCH')
	add_state('LEDGE_HOLD')
	add_state('LEDGE_CLIMB')
	add_state('LEDGE_JUMP')
	add_state('LEDGE_ROLL')
	
	add_state('WALL')
	add_state('WALL_JUMP')
	add_state('WALL_SLIDE')
	add_state('WALL_RUN')
	
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
	
	if parent.regrab > 0:
		parent.regrab -= 1

func get_transition(_delta):
	
	if parent.frame % 2 == 0 :
		parent._rotate()
	
	#parent._rotate()
	parent.move_and_slide()

	if LANDING() == true:
		parent._frame()
		return states.LANDING 
		
	if FALLING() == true:
		return states.AIR
		
	if PLATFORM_COLLIDED() == true :
		parent._frame()
		return states.PLATFORM_STAND
	else:
		pass
		
	if LEDGE() == true:
		parent._frame()
		return states.LEDGE_CATCH
	else:
		parent.reset_legde()
		
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
			
	
	match state:
		
		states.STAND:
#			print("idle")
			parent.reset_legde()
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
				if parent.frame >= parent.dash_duration-1:
					for ss in states:
						if ss != "JUMP_SQUAT":
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
					#changes from states to ss
					for ss in states:
						if ss != "JUMP_SQUAT":
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
			#if Input.is_action_just_pressed("jump"):                   -------- debug jump states
				#print(parent.airJump)
			# double jump
			if Input.is_action_just_pressed("jump") and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left"):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right"):
					parent.velocity.x += parent.MAXAIRSPEED
					
			# air attack
			if Input.is_action_just_pressed("mid"):
				parent._frame()
				return states.BOW_AIR
				
			if parent._is_on_wall():
				parent._frame()
				return states.WALL
			
		states.AIR_DASH:
			
			pass
			
		states.SLIDE:
			if parent.frame >= parent.slide_duration+1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent._frame()
							return states.STAND
			
		states.ROLL:
			print("rolling")
			if Input.is_action_just_released("down"):
				parent._frame()
				return states.AIR
		
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
					parent.reset_Jumps()
					return states.CROUCH
				else:
#					print_debug("broke my knees as i touched the ground")
					parent._frame()
					parent.reset_Jumps()
					parent.lag_frames = 0
					
				parent.lag_frames = 0
				
				if _on_platform():
					return states.PLATFORM_STAND
				else:
					return states.STAND
			
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
		
		
		#Ledge and Wall states
		states.LEDGE_CATCH:
			if parent.frame > 7:
				parent.lag_frames = 0
				parent.reset_Jumps()
				parent._frame()
				return states.LEDGE_HOLD
				
		states.LEDGE_HOLD:
			if parent.frame >= 360:
				self.parent.position.y += -25
				parent._frame()
#				return states.TUMBLE
				return states.AIR
			if Input.is_action_just_pressed("down"):
				parent.fastfall = true
				parent.regrab  =30
				parent.reset_legde()
				self.parent.position.y += -25
				parent.catch = false
				parent._frame()
				return states.AIR
			#Facing Right
			elif parent.Ledge_Grab_F.get_target_position().x > 0:
				if Input.is_action_just_pressed("left"):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab  = 30
					parent.reset_legde()
					self.parent.position.y += -25
					parent.catch = false
					parent._frame()
					return states.AIR
				elif Input.is_action_just_pressed("right"):
					parent._frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield"):
					parent._frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump"):
					parent._frame()
					return states.LEDGE_JUMP
			
			#Facing Right
			elif parent.Ledge_Grab_F.get_target_position().x < 0:
				#parent.turn(true)
				if Input.is_action_just_pressed("right"):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab  = 30
					parent.reset_legde()
					self.parent.position.y += -25
					parent.catch = false
					parent._frame()
					return states.AIR
				elif Input.is_action_just_pressed("left"):
					parent._frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield"):
					parent._frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump"):
					parent._frame()
					return states.LEDGE_JUMP
					
		states.LEDGE_CLIMB:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 25
			if parent.frame == 10:
				parent.position.y -= 25
			if parent.frame == 20:
				parent.position.y -= 25
			if parent.frame == 22:
				parent.catch = false
				parent.position.y -= 10#25
				parent.position.x += 15 * parent.direction()#50 * parent.direction()
			if parent.frame == 25:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.move_and_collide(Vector2(parent.direction()*20,50))
			if parent.frame == 30:
				parent.reset_legde()
				parent._frame()
				return states.STAND
				
		states.LEDGE_JUMP:
			if parent.frame > 14:
				#if Input.is_action_just_pressed("attack"):
					#parent._frame()
					#return states.AIR_ATTACK
				#if Input.is_action_just_pressed("special"):
					#parent._frame()
					#return states.SPECIAL
					pass
			if parent.frame == 5:
				parent.reset_legde()
				parent.position.y -= 20
			if parent.frame == 10:
				parent.catch = false
				parent.position.y -= 20
				if Input.is_action_just_pressed("jump") and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent._frame()
					return states.AIR
			if parent.frame == 15:
				parent.position.y -= 20
				parent.velocity.y -= parent.DOUBLEJUMPFORCE
				parent.velocity.x += 220*parent.direction()
				if Input.is_action_just_pressed("jump") and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent._frame()
					return states.AIR
				#if Input.is_action_just_pressed("attack"):
					#parent._frame()
					#return states.AIR_ATTACK
			elif parent.frame > 15 and parent.frame < 20 :
				parent.velocity.y += parent.FALLSPEED
				if Input.is_action_just_pressed("jump") and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.y = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent._frame()
					return states.AIR
				#if Input.is_action_just_pressed("attack"):
					#parent._frame()
					#return states.AIR_ATTACK
			if parent.frame == 20 :
				parent._frame()
				return states.AIR
				
		states.LEDGE_ROLL:
			if parent.frame == 1:
				pass
			if parent.frame == 5:
				parent.position.y -= 30
			if parent.frame == 10:
				parent.position.y -= 30
			if parent.frame == 20:
				parent.catch = false
				parent.position.y -= 30
			if parent.frame == 22:
				parent.position.y -= 30
				parent.position.x += 50 * parent.direction()
			if parent.frame > 22 and parent.frame < 28:
				parent.position.x += 30 * parent.direction()
			if parent.frame == 29:
				parent.move_and_collide(Vector2(parent.direction()*20,50))
			if parent.frame == 30:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.reset_legde()
				parent._frame()
				return states.STAND
		
		
		#Wall Movements
		states.WALL:
			AIRMOVEMENT()
			# flip sprite
			if parent.Wall_Cast_B.is_colliding():
				parent.turn(true)
			elif parent.Wall_Cast_F.is_colliding():
				parent.turn(false)
				
			# Handle Wall Run
			if Input.is_action_pressed("up"):
				parent._frame()
				return states.WALL_RUN
				
			# Handle Wall Jump
			if Input.is_action_pressed("jump"):
				parent._frame()
				return states.WALL_JUMP
				
			# Handle Wall Slide
			if Input.is_action_just_pressed("down"):
				parent._frame()
				return states.WALL_SLIDE
				
			## Handle Wall Run
			#if Input.is_action_just_pressed("up"):
				#parent._frame()
				#return states.WALL_RUN
				
			# Handle Fast Fall from Wall
			if parent.frame >= 120:
				parent._frame()
				parent.velocity.y -= 20
				parent.fastfall = true
				return states.AIR
				
		states.WALL_JUMP:
			#print("wall jumping")
			
			if Input.is_action_pressed("jump") and Input.is_action_pressed("left"):
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.JUMPFORCE
				parent.velocity.x = -parent.MAXAIRSPEED
				
			elif Input.is_action_pressed("jump") and Input.is_action_pressed("right"):
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.JUMPFORCE
				parent.velocity.x += parent.MAXAIRSPEED
				
			else:
				# double jump
				if Input.is_action_just_pressed("jump") and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity.x = 0
					parent.velocity.y = -parent.JUMPFORCE
					parent.airJump -= 1
					if Input.is_action_pressed("left"):
						parent.velocity.x = -parent.MAXAIRSPEED
					elif Input.is_action_pressed("right"):
						parent.velocity.x += parent.MAXAIRSPEED
						
				if parent.frame >= 20:
					parent._frame()
					return states.AIR
				
			AIRMOVEMENT()
			
		states.WALL_SLIDE:
			if Input.is_action_just_pressed("jump"):
				parent._frame()
				parent.velocity = Vector2.ZERO
				return states.WALL_JUMP
			else:
				if parent.Wall_Cast_B.is_colliding():
					parent.velocity.x -= parent.AIR_ACCEL
					parent.turn(true)
				elif parent.Wall_Cast_F.is_colliding():
					parent.velocity.x += parent.AIR_ACCEL
					parent.turn(false)
					
			AIRMOVEMENT()
			parent.fastfall = true
			
		states.WALL_RUN:
			if Input.is_action_pressed("up"):
				# add to the parent y velocity
				parent.velocity.y = -parent.RUNSPEED
				#flip the sprite based on ehich side is colliding with the wall
				if parent.Wall_Cast_B.is_colliding():
					#parent.velocity.x -= parent.AIR_ACCEL
					parent.turn(true)
				elif parent.Wall_Cast_F.is_colliding():
					#parent.velocity.x += parent.AIR_ACCEL
					parent.turn(false)
					
			else :
				parent.velocity.y = 0
				#parent.velocity.y
				parent._frame()
				return states.AIR
		
		
		#PLatform States 
		states.PLATFORM_STAND:
			
			if parent.frame == 0:
				parent.velocity.y += parent.FALLSPEED + parent.FALLSPEED
			parent.velocity = Vector2.ZERO
			
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
				parent.velocity.x = -parent.RUNSPEED
				parent.velocity.y = parent.FALLSPEED
				if parent.is_upside_down == true:
					parent.turn(false)
				else:
					parent.turn(true)
				#print("velocity : " , parent.velocity , " - Runspeed : " , parent.RUNSPEED)   ---------- debugging
			elif Input.is_action_pressed("right"):
				parent.velocity.x = parent.RUNSPEED
				parent.velocity.y = parent.FALLSPEED
				if parent.is_upside_down == true:
					parent.turn(true)
				else:
					parent.turn(false)
				#print("velocity : " , parent.velocity , " - Runspeed : " , parent.RUNSPEED)    ---------- debugging
			else:
				parent._frame()
				return states.PLATFORM_STAND
				
			if parent.frame >= 30:
				parent._frame()
			
		states.PLATFORM_JUMP:
			parent.calculate_jump_velocity()
			return states.JUMP_SQUAT
			
		states.PLATFORM_DASH:
			parent.velocity.y = parent.FALLSPEED
			
			if Input.is_action_pressed("jump"):
				parent._frame()
				return states.PLATFORM_JUMP
			
			elif Input.is_action_pressed("left"):
				if parent.velocity.x > 0:
					parent.turn(true)
				parent.velocity.x = -parent.DASHSPEED      #----- test 1
				#parent.velocity.x = -parent.DASHSPEED * 2  #----- test 2
				if parent.frame <= parent.dash_duration + 1:
					parent.turn(true)
					return states.PLATFORM_DASH
				else:
					parent.turn(false)
					return states.PLATFORM_RUN
				
			elif Input.is_action_pressed("right"):
				if parent.velocity.x < 0:
					parent.turn(false)
				parent.velocity.x = parent.DASHSPEED       #----- test 1
				#parent.velocity.x = parent.DASHSPEED * 2  #----- test 2
				if parent.frame <= parent.dash_duration + 1:
					parent.turn(false)
					return states.PLATFORM_DASH
				else:
					parent.turn(false)
					return states.PLATFORM_RUN
			else:
				if parent.frame >= parent.dash_duration+1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent._frame()
							return states.PLATFORM_STAND
		
		
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
			#if parent.frame >= 10:
				#parent._frame()
				#return states.STAND
				#
			parent._frame()
			return states.PUNCH_1
		
		states.PUNCH_1:
			if parent.frame == 0:
				parent.attack.Punch_1()
			#if parent.frame > 23:
			if parent.frame >= 13:
				if Input.is_action_pressed("heavy"):
					parent._frame()
					return states.PUNCH_2
			if parent.attack.Punch_1() == true:
				parent._frame()
				return states.STAND
		
		states.PUNCH_2:
			if parent.frame == 0:
				parent.attack.Punch_2()
				
			# condition to next attack
			if parent.frame >= 8 :
				#if Input.is_action_pressed("heavy"):
				if Input.is_action_just_pressed("heavy"):
					parent._frame()
					return states.PUNCH_3
				if Input.is_action_just_pressed("light"):
					parent._frame()
					return states.KICK_2
					
			# condition to end attack
			if parent.attack.Punch_2() == true:
				parent._frame()
				return states.STAND
		
		states.PUNCH_3:
			if parent.frame == 0:
				parent.attack.Punch_3()
			if parent.anim.is_playing() == false:
				parent._frame()
				return states.STAND
			else : if parent.attack.Punch_3() == true:
				# chain attacks
				parent._frame()
				#return states.STAND
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
			
		## ledge animations
		states.LEDGE_CATCH:
			parent.play_animation('ledge_catch')
			parent.states.text = str('LEDGE_CATCH')
		states.LEDGE_HOLD:
			parent.play_animation('ledge_hold')
			parent.states.text = str('LEDGE_HOLD')
		states.LEDGE_JUMP:
			parent.play_animation('ledge_jump')
			parent.states.text = str('LEDGE_JUMP')
		states.LEDGE_CLIMB:
			parent.play_animation('ledge_climb')
			parent.states.text = str('LEDGE_CLIMB')
		states.LEDGE_ROLL:
			parent.play_animation('ledge_roll')
			parent.states.text = str('LEDGE_ROLL')
			
		##  wall animations
		states.WALL:
			parent.play_animation('wall_idle')
			parent.states.text = str('WALL')
		states.WALL_JUMP:
			parent.play_animation('ledge_roll')
			parent.states.text = str('WALL_JUMP')
		states.WALL_SLIDE:
			parent.play_animation('wall_slide')
			parent.states.text = str('WALL_SLIDE')
		states.WALL_RUN:
			parent.play_animation('wall_run')
			parent.states.text = str('WALL_RUN')
			
		## platform animations
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
	#var sprite_y_offset = $"../Node2D/Sprite".global_transform.origin
	if state_includes([states.AIR , states.BOW_AIR , states.WALL , states.WALL_SLIDE]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y >= 0:# - sprite_y_offset.y:
			var _collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
		elif (parent.GroundR.is_colliding()) and parent.velocity.y >= 0 :#-  sprite_y_offset.y:
			var _collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
		#print(parent.velocity.y)
		#elif parent.Platform_Cast_D.is_colliding() and parent.velocity.y > 0 -  sprite_y_offset.y :
			#var colliser = parent.Platform_Cast_D.get_collider()
			#parent.frame = 0
			#if parent.velocity.y > 0:
				#parent.velocity.y = 0
			#return true
	
func FALLING():
	if state_includes([states.STAND ,states.DASH,states.MOONWALK,states.RUN,states.CROUCH,states.WALK,states.PLATFORM_STAND ,states.PLATFORM_RUN, states.PLATFORM_DASH ]):
		if parent.GroundL.is_colliding() or parent.GroundR.is_colliding() :
		#if parent.GroundL.is_colliding() and parent.GroundR.is_colliding() :
			return false
		else:
			return true
	
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
	if state_includes([states.AIR , states.BOW_AIR ]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false
	
func LEDGE():
	if state_includes([states.AIR]):
		if (parent.Ledge_Grab_F.is_colliding()):
			var collider = parent.Ledge_Grab_F.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down") > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				#self.parent.position.y = collider.position.y - 2
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down") > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20 #not sure mifhgt change
				#self.parent.position.y = collider.position.y + 2 #not sure mifhgt change
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
		if (parent.Ledge_Grab_B.is_colliding()):
			var collider = parent.Ledge_Grab_B.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down") > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				#self.parent.position.y = collider.position.y - 1
				parent.turn(false)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down") > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20 #not sure mifhgt change
				#self.parent.position.y = collider.position.y + 2 #not sure mifhgt change
				parent.turn(true)
				parent.reset_Jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
	pass


