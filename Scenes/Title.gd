extends Node2D

const NEW_GAME_SCENE = "res://Scenes/Campaign/CampaignManager.tscn"

func _ready():
	global.game_state = global.TITLE

func _on_Start_pressed():
	global.game_state = global.NEW_GAME
	global.change_scene(NEW_GAME_SCENE)
