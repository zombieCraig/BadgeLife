tool
extends Node2D

# The replaceable color is 255,0,205
export(float, 0, 1, 0.01) var hat_color setget set_hat_color

func set_hat_color(color):
	if has_node("CharProfileHat") == true:
		var mat = $CharProfileHat.get("material")
		mat.set_shader_param("u_replacement_color", Color(color,color,color))

func _ready():
	$CenterContainer/VBoxContainer/UserName.grab_focus()