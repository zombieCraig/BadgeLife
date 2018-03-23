extends Node2D

func update_dir():
	$Character2.input_direction = $Character.input_direction
	$Character.update_direction()
	$Character2.update_direction()

func _ready():
	$Character.input_direction = Vector2(1, 0)
	update_dir()

func _on_Timer_timeout():
	if $Character.last_move_direction == Vector2(1,0):
		$Character.input_direction = Vector2(0, 1)
	elif $Character.last_move_direction == Vector2(0, 1):
		$Character.input_direction = Vector2(-1, 0)
	elif $Character.last_move_direction == Vector2(-1, 0):
		$Character.input_direction = Vector2(0, -1)
	elif $Character.last_move_direction == Vector2(0, -1):
		$Character.input_direction = Vector2(1, 0)
	update_dir()
