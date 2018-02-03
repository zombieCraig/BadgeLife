tool
extends Node2D


# Test Alignment
var specialty = 0.5  # 0 = Red/Attack 1 = Blue/Defense
var alignment = 0.5 # 0 = Blackhat 1 = Whitehat
var alignStatus = "Chaotic Neutral"

func get_align_status():
	if alignment < 0.25:   # EVIL
		if specialty < 0.25:  # ATTACK
			return "Blackhat Hacker"
		elif specialty < 0.75:
			return "Darknet Soldier"
		else:                 # DEFENSE
			return "DRM Developer"
	elif alignment < 0.75: # NEUTRAL
		if specialty < 0.25:
			return "Chaotic Evil"  # ATTACK
		elif specialty < 0.75:
			return "Chaotic Neutral"
		else:
			return "Chaotic Good"  # DEFENSE
	else:                 # GOOD
		if specialty < 0.25:  # ATTACK
			return "Red Teamer"
		elif specialty < 0.75:
			return "Infosec Warrior"
		else:                 # DEFENSE
			return "SIEM Master"

func updateStatus():
	alignStatus = get_align_status()
	$TestPanel/Status.text = alignStatus
	set_hat_to_alignment()


func set_hat_to_alignment():
	var hat_color = Color()
	# Specialty Red-Blue
	hat_color.r = 1 - specialty
	hat_color.g = 0
	hat_color.b = specialty
	# Alignment Black-White
	hat_color *= max(0.2, alignment)
	hat_color.a = 1
	if has_node("CharProfileHat") == true:
		var mat = $CharProfileHat.get("material")
		mat.set_shader_param("u_replacement_color", hat_color)


func _ready():
	$CenterContainer/VBoxContainer/UserName.grab_focus()
	updateStatus()
	set_hat_to_alignment()

func _on_SpecialtySlider_value_changed( value ):
	specialty = value
	updateStatus()


func _on_AlignSlider_value_changed( value ):
	alignment = value
	updateStatus()
