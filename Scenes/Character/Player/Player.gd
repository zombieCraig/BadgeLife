extends "res://Scenes/Character/Character.gd"

# Rotates the raycast2d when we turn
func set_raycast():
	if input_direction.y == -1: # DOWN
		$CenterCast.set("cast_to", Vector2(0, -50))
		$LeftCast.set("cast_to", Vector2(0, -50))
		$LeftCast.set("position", Vector2(-14, 0))
		$RightCast.set("cast_to", Vector2(0, -50))
		$RightCast.set("position", Vector2(14, 0))
	elif input_direction.y == 1: # UP
		$CenterCast.set("cast_to", Vector2(0, 50))
		$LeftCast.set("cast_to", Vector2(0, 50))
		$LeftCast.set("position", Vector2(14, 0))
		$RightCast.set("cast_to", Vector2(0, 50))
		$RightCast.set("position", Vector2(-14, 0))
	elif input_direction.x == 1: # Right
		$CenterCast.set("cast_to", Vector2(50, 0))
		$LeftCast.set("cast_to", Vector2(50, 0))
		$LeftCast.set("position", Vector2(0, -14))
		$RightCast.set("cast_to", Vector2(50, 0))
		$RightCast.set("position", Vector2(0, 4))
	elif input_direction.x == -1: # Left
		$CenterCast.set("cast_to", Vector2(-50, 0))
		$LeftCast.set("cast_to", Vector2(-50, 0))
		$LeftCast.set("position", Vector2(0, 4))
		$RightCast.set("cast_to", Vector2(-50, 0))
		$RightCast.set("position", Vector2(0, -14))

# Return true if any collider is hitting something
func cast_colliding():
	return $CenterCast.is_colliding() or $LeftCast.is_colliding() or $RightCast.is_colliding()

# Gets the colliding object.  priority is center, left then right
func get_collider():
	if $CenterCast.is_colliding():
		return $CenterCast.get_collider()
	if $LeftCast.is_colliding():
		return $LeftCast.get_collider()
	if $RightCast.is_colliding():
		return $RightCast.get_collider()
	return null

# Since the super class has no idea about the RayCasts we have to record
# them when running to the super class to handle bumping physics
func record_colliders():
	left_collider = $LeftCast.is_colliding()
	right_collider = $RightCast.is_colliding()
	center_collider = $CenterCast.is_colliding()

func _physics_process(delta):
	input_direction = Vector2()
	
	if global.block_player_input:
		return
	
	# 4 Direction lock
#	if Input.is_action_pressed('move_up'):
#		input_direction.y = -1
#	elif Input.is_action_pressed('move_down'):
#		input_direction.y = 1
#	elif Input.is_action_pressed('move_right'):
#		input_direction.x = 1
#	elif Input.is_action_pressed('move_left'):
#		input_direction.x = -1

	# Condenced version of above, tip from GDQuest
	input_direction.y = float(Input.is_action_pressed('move_down')) - float(Input.is_action_pressed('move_up'))
	if not input_direction.y:
		input_direction.x = float(Input.is_action_pressed('move_right')) - float(Input.is_action_pressed('move_left'))

	# Run
	max_speed = MAX_RUN_SEED if Input.is_action_pressed('run') else MAX_WALK_SPEED
	if max_speed == MAX_RUN_SEED:
		record_colliders()

	set_raycast()
	if Input.is_action_just_pressed('interact'):
		if cast_colliding():
			var obj = get_collider()
			if obj.has_method("interact"):
				obj.interact()

func _ready():
	guile = global.player["guile"]
	mental = global.player["mental"]
	power = global.player["power"]
	if global.player.has("last_save_pos"):
		position = global.player["last_save_pos"]
