extends Node

# For now using a global hash for the player data
var player = { "name": "Hacker"}

# Simple shorthand to change scenes
func change_scene(new_scene):
	get_tree().change_scene(new_scene)