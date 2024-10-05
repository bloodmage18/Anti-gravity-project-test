extends StateMachine
@onready var parent = get_parent()
@onready var id = parent.id

func _ready():
	add_state('STAND')
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('DASH')
	add_state('RUN')
	add_state('MOONWALK')
	add_state('WALK')
	add_state('TURN')
	add_state('CROUCH')
	add_state('AIR')
	add_state('LANDING')
	add_state('LEDGE_CATCH')
	add_state('LEDGE_HOLD')
	add_state('LEDGE_CLIMB')
	add_state('LEDGE_JUMP')
	add_state('LEDGE_ROLL')
	add_state('HIT_STUN')
	add_state('HITFREEZE')
	add_state('GROUND_ATTACK')
	add_state('JAB')
	add_state('JAB_1')
	add_state('DOWN_TILT')
	add_state('FORWARD_TILT')
	add_state('UP_TILT')
	add_state('AIR_ATTACK')
	add_state('NAIR')
	add_state('UAIR')
	add_state('BAIR')
	add_state('FAIR')
	add_state('DAIR')
	call_deferred("set_state", states.STAND)

func state_logic(delta):
	parent.updateframes(delta)
	parent._physics_process(delta)
	if parent.regrab > 0:
		parent.regrab -= 1
	parent.hit_pause(delta)

func get_transition(delta):
#	parent.move_and_slide_with_snap(parent.velocity*2,Vector2.ZERO,Vector2.UP)
	parent.move_and_slide(parent.velocity * 2 , Vector2.UP)
#	parent.move_and_slide_with_snap(parent.velocity*2,Vector2.DOWN,Vector2.UP)
	
	if landing() == true :
		parent.frame()
		return states.LANDING
#
	if Falling() == true:
		return states.AIR
		
	if Ledge() == true:
		parent.frame()
		return states.LEDGE_CATCH
	else:
		parent.reset_ledge()
	
	if Input.is_action_just_pressed("attack_%s" % id) && TILT() == true :
		parent.frame()
		return states.GROUND_ATTACK
	
	if Input.is_action_just_pressed("attack_%s" % id) && AIREAL() == true:
			if Input.get_action_strength("up_%s" % id):
				parent.frame()
				return states.DASH
			if Input.get_action_strength("down_%s" % id):
				parent.frame()
				return states.DASH
				
			match parent.direction():
				1:
					if Input.get_action_strength("right_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.get_action_strength("left_%s" % id):
						parent.frame()
						return states.FAIR
				-1:
					if Input.get_action_strength("right_%s" % id):
						parent.frame()
						return states.BAIR
					if Input.get_action_strength("left_%s" % id):
						parent.frame()
						return states.FAIR
			parent.frame()
			return states.NAIR
			
	if Input.is_action_just_pressed("shield_%s" % id) && !AIREAL() && parent.cooldown == 0:
		parent.l_cancel == 1
		parent.cooldown = 40
		print_debug("L cancel = true")
	
	match state:
		states.STAND:
#			print_debug("Standing")
			parent.reset_jumps()
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent.frame()
				parent.turn(false)
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.RUNSPEED
				parent.frame()
				parent.turn(true)
				return states.DASH
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION*1
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			
		states.JUMP_SQUAT:
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerp(parent.velocity.x , 0 , 0.08)
					parent.frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerp(parent.velocity.x , 0 , 0.08)
					parent.frame()
					return states.FULL_HOP
		
		states.SHORT_HOP:
#			print_debug("short hop")
			parent.velocity.y = -parent.JUMPFORCE
			parent.frame()
			return states.AIR
			
		states.FULL_HOP:
#			print_debug("full hop")
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.frame()
			return states.AIR
			
		states.DASH:
#			print_debug("dashing")
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			
			elif Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x = -parent.DASHSPEED
				if parent.frame <= parent.dash_duration+1:
					if Input.is_action_just_pressed("down_%s"% id):
						parent.frame()
						return states.MOONWALK
					parent.turn(true)
					return states.DASH
				else:
					parent.turn(true)
					parent.frame()
					return states.RUN
					
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x = parent.DASHSPEED
				if parent.frame <= parent.dash_duration+1:
					if Input.is_action_just_pressed("down_%s"% id):
						parent.frame()
						return states.MOONWALK
					parent.turn(false)
					return states.DASH
				else:
					parent.turn(false)
					parent.frame()
					return states.RUN
			else:
				if parent.frame >= parent.dash_duration-1:
					for state in states:
						if state != "JUMP_SQUAT":
							parent.frame()
							return states.STAND
		
		states.RUN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
				
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
				
			if Input.get_action_strength("left_%s" % id):
				if parent.velocity.x <= 0:
					parent.velocity.x = -parent.RUNSPEED
					parent.turn(true)
#					parent.turn(false)
				else:
					parent.frame()
					return states.TURN
			elif Input.get_action_strength("right_%s" % id):
				if parent.velocity.x >= 0:
					parent.velocity.x = parent.RUNSPEED
					parent.turn(false)
#					parent.turn(true)
				else:
					parent.frame()
					return states.TURN
			else:
				parent.frame()
				return states.TURN
				
		states.TURN:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if parent.velocity.x > 0:
#				parent.turn(true)
				parent.turn(false)
				parent.velocity.x += -parent.TRACTION*2
				parent.velocity.x =  clamp(parent.velocity.x , 0 , parent.velocity.x)
			elif parent.velocity.x < 0:
				parent.turn(true)
#				parent.turn(false)
				parent.velocity.x += parent.TRACTION*2
				parent.velocity.x =  clamp(parent.velocity.x , parent.velocity.x , 0)
			else:
				if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
					parent.frame()
					return states.STAND
				else:
					parent.frame()
					return states.RUN
				
		states.MOONWALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
				
			elif Input.is_action_pressed("left_%s" % id) && parent.direction() == 1:
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x += -parent.AIR_ACCEL * Input.get_action_strength("left_%s"% id)
				parent.velocity.x = clamp(parent.velocity.x, -parent.DASHSPEED * 1.4 , parent.velocity.x)
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent.frame()
					return states.STAND
					
			elif Input.is_action_pressed("right_%s" % id) && parent.direction() == -1:
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x += parent.AIR_ACCEL * Input.get_action_strength("right_%s"% id)
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x , parent.DASHSPEED * 1.5 )
				if parent.frame <= parent.dash_duration * 2:
					parent.turn(false)
					return states.MOONWALK
				else:
					parent.turn(true)
					parent.frame()
					return states.STAND
			
			else:
				if parent.frame > parent.dash_duration - 1 :
					for state in states:
						if state != "JUMP_SQUAT":
							return states.STAND
			
		states.WALK:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_pressed("down_%s" % id):
				parent.frame()
				return states.CROUCH
			if Input.get_action_strength("left_%s" % id):
				parent.velocity.x = -parent.WALKSPEED * Input.get_action_strength("left_%s" % id)
				parent.turn(true)
			elif Input.get_action_strength("right_%s" % id):
				parent.velocity.x = parent.WALKSPEED * Input.get_action_strength("right_%s" % id)
				parent.turn(false)
			else:
				parent.frame()
				return states.STAND
				
		states.CROUCH:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT
			if Input.is_action_just_released("down_%s" % id):
				parent.frame()
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
				
		states.AIR:
#			print_debug("AIR")
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s"% id) and parent.airJump > 0:
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("left_%s"%id):
					parent.velocity.x = -parent.MAXAIRSPEED
				elif Input.is_action_pressed("right_%s"%id):
					parent.velocity.x = parent.MAXAIRSPEED
			
		states.LANDING:
#			if parent.frame <= parent.landing_frames + parent.lag_frames:
#				if parent.frame == 1:
#					pass
			if parent.frame == 1:
				if parent.l_cancel > 0:
					parent.lag_frames = floor(parent.lag_frames / 2)
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x , 0 , parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x , parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump_%s" % id):
#					print_debug("jumped")
					parent.frame()
					return states.JUMP_SQUAT
#					print_debug("moving to jump_squat")
			else:
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.frame()
					parent.reset_jumps()
					return states.CROUCH
				else:
#					print_debug("broke my knees as i touched the ground")
					parent.frame()
					parent.reset_jumps()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0
				
		states.LEDGE_CATCH:
			if parent.frame > 7:
				parent.lag_frames = 0
				parent.reset_jumps()
				parent.frame()
				return states.LEDGE_HOLD
			
		states.LEDGE_HOLD:
			if parent.frame >= 360:
				self.parent.position.y += -25
				parent.frame()
#				return states.TUMBLE
				return states.AIR
			if Input.is_action_just_pressed("down_%s"% id):
				parent.fastfall = true
				parent.regrab  =30
				parent.reset_ledge()
				self.parent.position.y += -25
				parent.catch = false
				parent.frame()
				return states.AIR
			#Facing Right
			elif parent.Ledge_Grab_F.get_cast_to().x > 0:
				if Input.is_action_just_pressed("left_%s"% id):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab  = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.frame()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s"% id):
					parent.frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s"% id):
					parent.frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s"% id):
					parent.frame()
					return states.LEDGE_JUMP
			
			#Facing Right
			elif parent.Ledge_Grab_F.get_cast_to().x < 0:
				if Input.is_action_just_pressed("right_%s"% id):
					parent.velocity.x = (parent.AIR_ACCEL/2)
					parent.regrab  = 30
					parent.reset_ledge()
					self.parent.position.y += -25
					parent.catch = false
					parent.frame()
					return states.AIR
				elif Input.is_action_just_pressed("right_%s"% id):
					parent.frame()
					return states.LEDGE_CLIMB
				elif Input.is_action_just_pressed("shield_%s"% id):
					parent.frame()
					return states.LEDGE_ROLL
				elif Input.is_action_just_pressed("jump_%s"% id):
					parent.frame()
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
				parent.position.y -= 25
				parent.position.x += 50 * parent.direction()
			if parent.frame == 25:
				parent.velocity.y = 0
				parent.velocity.x = 0
				parent.move_and_collide(Vector2(parent.direction()*20,50))
			if parent.frame == 30:
				parent.reset_ledge()
				parent.frame()
				return states.STAND
			
		states.LEDGE_JUMP:
			if parent.frame > 14:
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.frame()
					return states.AIR_ATTACK
				if Input.is_action_just_pressed("special_%s" % id):
					parent.frame()
					return states.SPECIAL
			if parent.frame == 5:
				parent.reset_ledge()
				parent.position.y -= 20
			if parent.frame == 10:
				parent.catch = false
				parent.position.y -= 20
				if Input.is_action_just_pressed("jump_%s"% id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.frame()
					return states.AIR
			if parent.frame == 15:
				parent.position.y -= 20
				parent.velocity.y -= parent.DOUBLEJUMPFORCE
				parent.velocity.x += 220*parent.direction()
				if Input.is_action_just_pressed("jump_%s"% id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.frame()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.frame()
					return states.AIR_ATTACK
			elif parent.frame > 15 and parent.frame < 20 :
				parent.velocity.y += parent.FALLSPEED
				if Input.is_action_just_pressed("jump_%s"% id) and parent.airJump > 0:
					parent.fastfall = false
					parent.velocity = -parent.DOUBLEJUMPFORCE
					parent.velocity.x = 0
					parent.airJump -= 1
					parent.frame()
					return states.AIR
				if Input.is_action_just_pressed("attack_%s" % id):
					parent.frame()
					return states.AIR_ATTACK
			if parent.frame == 20 :
				parent.frame()
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
				parent.reset_ledge()
				parent.frame()
				return states.STAND
			
		states.HIT_STUN:
			if parent.knockback >= 3:
				var bounce = parent.move_and_collide(parent.velocity * delta)
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.normal) * 0.8
					parent.hitstun = round(parent.hitstun * 0.8)
			if parent.velocity.y < 0 :
				parent.velocity.y += parent.vdecay * 0.5 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y , parent.velocity.y , 0) 
			if parent.velocity.x < 0 :
				parent.velocity.x += (parent.hdecay) * 0.4 * -1 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x , parent.velocity.x , 0) 
			if parent.velocity.x > 0 :
				parent.velocity.x -= parent.hdecay * 0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x ,  0, parent.velocity.x) 
					
			if parent.frame >= parent.hitstun:
				if parent.knockback >= 24:
					parent.frame()
					return states.AIR
				else:
					parent.frame()
					return states.AIR
			elif parent.frame > 60*5:
				return states.AIR
			
		states.HITFREEZE:
			if parent.freezrframes == 0:
				parent.frame()
				parent.velocity.x = kbx
				parent.velocity.y = kby
				parent.hdecay = hd
				parent.vdecay = vd
				return states.HIT_STUN
			parent.position = pos
			
		states.GROUND_ATTACK:
			if Input.is_action_pressed("up_%s"%id):
				parent.frame()
				return states.UP_TILT
			if Input.is_action_pressed("down_%s"%id):
				parent.frame()
				return states.DOWN_TILT
			if Input.is_action_pressed("left_%s"%id):
				parent.turn(true)
				parent.frame()
				return states.FORWARD_TILT
			if Input.is_action_pressed("right_%s"%id):
				parent.turn(false)
				parent.frame()
				return states.FORWARD_TILT
			parent.frame()
			return states.JAB
			
		states.JAB:
			if parent.frame == 0:
				parent.JAB()
#				print_debug("Jab 1 initiated")
				
			if Input.is_action_just_pressed("attack_%s" % id) and parent.frame < 10:#parent.jab_duration:    
#				parent.frame()
				return states.JAB_1	        
				
			if parent.JAB() == true:
				parent.frame()
				return states.STAND
		
		states.JAB_1:
			if parent.frame >= 10:
				parent.JAB_1()
#				print_debug("Jab 2 initiated")       
				
			if parent.JAB_1() == true:
				parent.frame()
				return states.STAND
		
		states.DOWN_TILT:
			if parent.frame == 0:
				parent.DOWN_TILT()
				pass
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x, 0 , parent.velocity.x)
				elif parent.velocity.x < 0 :
					parent.velocity.x += parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x , 0)
			if parent.DOWN_TILT() == true:
				if Input.is_action_pressed("down_%s" % id):
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					return states.STAND
					
		states.FORWARD_TILT:
			if parent.frame == 0:
				parent.FORWARD_TILT()
				pass
			
			if parent.FORWARD_TILT() == true:
#				if Input.is_action_pressed("down_%s" % id):
#					parent.frame()
#					return states.CROUCH
#				else:
					parent.frame()
					return states.STAND
					
		states.UP_TILT:
			if parent.frame == 0:
				parent.frame()
				parent.UP_TILT()
			if parent.frame >= 1:
				if parent.velocity.x > 0:
					parent.velocity.x += -parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x, 0 , parent.velocity.x)
				elif parent.velocity.x < 0 :
					parent.velocity.x += parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x , 0)
			if parent.UP_TILT() == true:
				parent.frame()
				return states.STAND
					
		states.AIR_ATTACK:
			AIRMOVEMENT()
			if Input.is_action_pressed("up_%s"% id):
				parent.frame()
				return states.UAIR
			if Input.is_action_pressed("down_%s"% id):
				parent.frame()
				return states.DAIR
			match parent.direction():
				1:
					if Input.is_action_pressed("left_%s"% id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("right_%s"% id):
						parent.frame()
						return states.FAIR
				-1:
					if Input.is_action_pressed("right_%s"% id):
						parent.frame()
						return states.BAIR
					if Input.is_action_pressed("left_%s"% id):
						parent.frame()
						return states.FAIR
			parent.frame()
			return states.NAIR
			
		states.NAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print_debug('nair')
				parent.NAIR()
			if parent.NAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
				
			elif parent.frame < 5 :
				parent.lag_frames = 0
			elif parent.frame > 15 :
				parent.lag_frames = 0
			else:
				# for frames before any action
				parent.lag_frames = 7
				
		states.UAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print_debug('uair')
				parent.UAIR()
			if parent.UAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
			else:
				parent.lag_frames = 13
				
		states.BAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print_debug('bair')
				parent.BAIR()
			if parent.BAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR
			else:
				parent.lag_frames = 9
				
		states.FAIR:
			AIRMOVEMENT()
			if Input.is_action_just_pressed("jump_%s" % id) and parent.airJump > 0 :
				parent.fastfall = false
				parent.velocity.x = 0
				parent.velocity.y = -parent.DOUBLEJUMPFORCE
				parent.airJump -= 1
				if Input.is_action_pressed("right_%s"% id):
					parent.velocity.x = -parent.MAXAIRSPEED 
				if Input.is_action_pressed("left_%s"% id):
					parent.velocity.x = parent.MAXAIRSPEED
				return states.AIR 
			if parent.frame == 0:
				print_debug('fair')
				parent.FAIR()
			if parent.FAIR() == true:
				parent.lag_frames = 30
				parent.frame()
				return states.FAIR
			else:
				parent.lag_frames = 10
				
		states.DAIR:
			AIRMOVEMENT()
			if parent.frame == 0:
				print_debug('dair')
				parent.DAIR()
			if parent.DAIR() == true:
				parent.lag_frames = 0
				parent.frame()
				return states.AIR

func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation('IDLE')
			parent.states.text = str('STAND')
		states.DASH:
			parent.play_animation('DASH')
			parent.states.text = str('DASH')
		states.MOONWALK:
			parent.play_animation('WALK')
			parent.states.text = str('MOONWALK')
		states.TURN:
			parent.play_animation('TURN')
			parent.states.text = str('TURN')
		states.CROUCH:
			parent.play_animation('CROUCH')
			parent.states.text = str('CROUCH')
		states.RUN:
			parent.play_animation('RUN')
			parent.states.text = str('RUN')
		states.JUMP_SQUAT:
			parent.play_animation('JUMP_SQUAT')
			parent.states.text = str('JUMP_SQUAT')
		states.SHORT_HOP:
			parent.play_animation('AIR')
			parent.states.text = str('SHORT HOP')
		states.FULL_HOP:
			parent.play_animation('AIR')
			parent.states.text = str('FULL HOP')
		states.AIR:
			parent.play_animation('AIR')
			parent.states.text = str('AIR')
		states.LANDING:
			parent.play_animation('LANDING')
			parent.states.text = str('LANDING')
		states.LEDGE_CATCH:
			parent.play_animation('LEDGE_CATCH')
			parent.states.text = str('LEDGE_CATCH')
		states.LEDGE_HOLD:
			parent.play_animation('LEDGE_CATCH')
			parent.states.text = str('LEDGE_HOLD')
		states.LEDGE_JUMP:
			parent.play_animation('AIR')
			parent.states.text = str('LEDGE_JUMP')
		states.LEDGE_CLIMB:
			parent.play_animation('ROLL_FORWARD')
			parent.states.text = str('LEDGE_CLIMB')
		states.LEDGE_ROLL:
			parent.play_animation('ROLL_FORWARD')
			parent.states.text = str('LEDGE_ROLL')
		states.HITFREEZE:
			parent.play_animation('HITSTUN')
			parent.states.text = str('HITFREEZE')
		states.HIT_STUN:
			parent.play_animation('HITSTUN')
			parent.states.text = str('HITSTUN')
		states.GROUND_ATTACK:
			parent.states.text = str('GROUND_ATTACK')
		states.JAB:
			parent.play_animation('JAB_1')
			parent.states.text = str('JAB')
		states.JAB_1:
#			parent.play_animation('JAB_1')
			parent.states.text = str('JAB_1')
		states.DOWN_TILT:
			parent.play_animation('DOWN_TILT')
			parent.states.text = str('DOWN_TILT')
		states.FORWARD_TILT:
			parent.play_animation('FORWARD_TILT')
			parent.states.text = str('FORWARD_TILT')
		states.UP_TILT:
			parent.play_animation('UP_TILT')
			parent.states.text = str('UP_TILT')
		states.AIR_ATTACK:
			parent.states.text = str('AIR_ATTACK')
		states.NAIR:
			parent.play_animation('NAIR')
			parent.states.text = str('NAIR')
		states.UAIR:
			parent.play_animation('UAIR')
			parent.states.text = str('UAIR')
		states.BAIR:
			parent.play_animation('BAIR')
			parent.states.text = str('BAIR')
		states.FAIR:
			parent.play_animation('FAIR')
			parent.states.text = str('FAIR')
		states.DAIR:
			parent.play_animation('DAIR')
			parent.states.text = str('DAIR')

func exit_state(old_state, new_state):
	pass

func state_includes(state_array):
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func TILT():
	if state_includes([states.STAND, states.MOONWALK , states.RUN , states.WALK , states.CROUCH]):
		return true

func AIREAL():
	if state_includes([states.AIR, states.DAIR , states.NAIR , states.BAIR , states.UAIR , states.FAIR]):
		if !(parent.GroundL.is_colliding() and parent.GroundR.is_colliding()):
			return true
		else:
			return false

func AIRMOVEMENT():
#	print_debug("i believe i can fly")
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y += parent.FALLSPEED
#	if Input.is_action_pressed("down_%s" & id) and parent.down_buffer == 1 and parent.velocity.y > -150 and not parent.fastfall :
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall :
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.set_collision_mask_bit(2,false)
		parent.velocity.y = parent.MAXFALLSPEED
		
	if abs(parent.velocity.x) >= abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.AIR_ACCEL
			
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL
		
	if not Input.is_action_just_released("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL/5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL/5

func landing():
#	print_debug("aaaaaa")
	if state_includes([states.AIR , states.BAIR, states.UAIR,states.FAIR, states.DAIR , states.NAIR]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
#			parent.frame()
#			return states.LANDING
#			print_debug("on_ground")
			
		elif (parent.GroundR.is_colliding()) and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
			parent.fastfall = false
			return true
			
func Falling():
#	if state_includes([states.STAND , states.FULL_HOP , states.DASH , states.WALK , states.CROUCH , states.LANDING , states.SHORT_HOP ,states.CROUCH ]):
	if state_includes([states.STAND ,states.DASH,states.MOONWALK,states.RUN,states.CROUCH,states.WALK ]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true
#			parent.frame()
		else:
			return false

func Ledge():
	if state_includes([states.AIR]):
		if (parent.Ledge_Grab_F.is_colliding()):
			var collider = parent.Ledge_Grab_F.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down_%s"% id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				self.parent.position.y = collider.position.y - 2
				parent.turn(false)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down_%s"% id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20 #not sure mifhgt change
				self.parent.position.y = collider.position.y + 2 #not sure mifhgt change
				parent.turn(true)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
		if (parent.Ledge_Grab_B.is_colliding()):
			var collider = parent.Ledge_Grab_B.get_collider()
			if collider.get_node('Label').text == 'Ledge_L' and !Input.get_action_strength("down_%s"% id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x - 20
				self.parent.position.y = collider.position.y - 1
				parent.turn(false)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
				
			if collider.get_node('Label').text == 'Ledge_R' and !Input.get_action_strength("down_%s"% id) > 0.6 and parent.regrab == 0 && !collider.is_grabbed :
				if state_includes([states.AIR]):
					if parent.velocity.y < 0:
						return false
				parent.frame = 0
				parent.velocity.x = 0
				parent.velocity.y = 0
				self.parent.position.x = collider.position.x + 20 #not sure mifhgt change
				self.parent.position.y = collider.position.y + 2 #not sure mifhgt change
				parent.turn(true)
				parent.reset_jumps()
				parent.fastfall = false
				collider.is_grabbed = true
				parent.last_ledge = collider
				return true
	pass

var kbx
var kby
var hd
var vd
var pos

func hitfreeze(duration, knockback):
	pos = parent.get_position()
	parent.freezrframes = duration
	kbx = knockback[0]
	kby = knockback[1]
	hd = knockback[2]
	vd = knockback[3]
