extends Node
class_name Attacks
@export var parent : Bob
var projectile_cooldown = 0




# HAND ATTACKS
func HAND_COMBO():

	pass

func Punch_1():
	if parent.frame == 7:
		#print("punch _ 01") --debug
		parent.create_hitbox(40,20,10,90,3,120,12,'normal',Vector2(25,0),0,1)
		#pass
	if parent.frame == 25:
		return true
	
func Punch_2():
	if parent.frame == 8:
		#print("punch _ 02") -- debug
		parent.create_hitbox(40,10,10,90,3,120,16,'normal',Vector2(30,0),0,1)
		#pass
	if parent.frame == 25:
		return true
		
func Punch_3():
	if parent.frame == 8:
		#print("punch _ 03") --debug
		parent.create_hitbox(30,27,10,90,3,120,31,'normal',Vector2(14,0),0,1)
		#pass
	if parent.frame == 40:
		return true

func KICK_A():
	if parent.frame == 8:
		#print("kick _ 01")  -- debug
		pass
	if parent.frame == 15:
		return true
		
func KICK_B():
	if parent.frame == 4:
		#print("kick _ 02") --debug
		pass
	if parent.frame == 12:
		return true

# SWORD ATTACKS
func SWORD_COMBO():
	
	pass

func SWRD_G1():pass
func SWRD_G2():pass
func SWRD_G3():pass

func SWRD_A1():
	
	pass
func SWRD_A2():
	
	pass
func SWRD_A3():
	
	pass

# Bow Attacks [AIR & GROUND]
func BOW_GROUND():
	if parent.frame == 11:
		parent.create_Projectile2(1,0,Vector2(35,0))
	if parent.frame == 14:
		return true
	
func BOW_AIR():
	if parent.frame == 2:
		parent.create_Projectile2(1,0,Vector2(35,0))
	if parent.frame == 14:
		return true
	
	
	
	
	
	
