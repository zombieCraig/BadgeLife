extends Node

# For now using a global hash for the player data
var player = { "name": "Hacker"}

# Global method to block player input (so they don't move
var block_player_input = false

# Simple shorthand to change scenes
func change_scene(new_scene):
	get_tree().change_scene(new_scene)