extends Node

@export var parent : CharacterBody2D
var projectile_cooldown = 0




# HAND ATTACKS

# SWORD ATTACKS
func swordsattacks():
	
	pass



# Bow Attacks [AIR & GROUND]
func BOW_GROUND():
	if parent.frame == 11:
		parent.create_Projectile(1,0,Vector2(50,-25))
	if parent.frame == 14:
		return true
	
func BOW_AIR():
	if parent.frame == 5:
		parent.create_Projectile(1,0,Vector2(50,-25))
	if parent.frame == 8:
		return true
	
	
	
	
	
	
