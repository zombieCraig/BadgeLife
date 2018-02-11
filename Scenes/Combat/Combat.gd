extends Control

func resize():
	var messages_size = $Messages.get("rect_size")
	$Messages/Tip.set("rect_min_size", messages_size - Vector2(80, 20))
	var menu_size = $Menu.get("rect_size")
	$Menu/CharSelect.set("rect_min_size", Vector2(360,menu_size.y))
	$Menu/ActionSelect.set("rect_min_size", Vector2(160, menu_size.y))
#	$Menu/OpponentSelect.set("rect_min_size", Vector2(menu_size.x - 520,menu_size.y))

func _ready():
	resize()