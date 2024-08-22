extends Node
var parent = get_parent()
var projectile_cooldown = 0


# HAND ATTACKS

# SWORD ATTACKS

# Bow Attacks [AIR & GROUND]
func GROUND_BOW():
	if parent.frame == 5:
		parent.create_Projectile(1,0,Vector2(50,0))
	if parent.frame == 8:
		return true
	
func AIR_BOW():
	if parent.frame == 5:
		parent.create_Projectile(1,0,Vector2(50,0))
	if parent.frame == 8:
		return true
	
	
	
	
	
	
