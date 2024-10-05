# StatePlatformMovement.gd
extends StateMachine

func enter():
	# Adjust rotation when entering the state
	_apply_rotation_to_platform()

func exit():
	# Reset the rotation when exiting the state
	owner.rotation = 0

func _physics_process(delta):
	_apply_platform_movement(delta)

func _apply_rotation_to_platform():
	if owner.raycastUp.is_colliding():
		var normal = owner.raycastUp.get_collision_normal()
		owner.rotation = normal.angle() + deg_to_rad(90)
	else:
		owner.rotation = 0

func _apply_platform_movement(delta):
	var input_dir = Input.get_vector("Left", "Right", "ui_down", "ui_up")
	var normal = owner.raycastDown.get_collision_normal()

	if input_dir.x != 0:
		owner.move_direction = normal.rotated(input_dir.x * deg_to_rad(90))
		owner.velocity.x = owner.move_direction.x * owner.Speed
		owner.velocity -= (normal * owner.Jump_Velocity) * delta
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, owner.Speed)

	# Attach the tank to the platform
	if owner.raycastUp.is_colliding() and !Input.is_action_just_pressed("jump"):
		owner._attach_to_platform(delta)
	else:
		owner._apply_gravity(delta)

	owner.move_and_slide()
