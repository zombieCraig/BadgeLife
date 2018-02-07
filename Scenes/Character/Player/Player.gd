extends "res://Scenes/Character/Character.gd"

func set_raycast():
	if input_direction.y == -1:
		$RayCast2D.set("cast_to", Vector2(0, -50))
	elif input_direction.y == 1:
		$RayCast2D.set("cast_to", Vector2(0, 50))
	elif input_direction.x == 1:
		$RayCast2D.set("cast_to", Vector2(50, 0))
	elif input_direction.x == -1:
		$RayCast2D.set("cast_to", Vector2(-50, 0))

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

	set_raycast()
	if Input.is_action_just_pressed('interact'):
		if $RayCast2D.is_colliding():
			var obj = $RayCast2D.get_collider()
			if obj.has_method("interact"):
				obj.interact()