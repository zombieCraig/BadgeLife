extends "res://Scenes/Character/NPCs/NPC.gd"

# Everything is random but the shirt.  That's always red
func _init_look():
	_random_gender()
	_random_skintone()
	_random_hair()
	base_torsowear_color = Color(0.92, 0.06, 0.06)
	base_legwear_color = Color(0.2, 0.2, 0.2)
	_random_footwear()
	update_body()

func _ready():
	_init_look()
	idle_movement = false
	$IdleTimer.stop()