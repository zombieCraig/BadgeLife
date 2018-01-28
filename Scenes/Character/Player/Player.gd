extends "res://Scenes/Character/Character.gd"

func _physics_process(delta):
	input_direction = Vector2()
	
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
	
	play_walk_animation()