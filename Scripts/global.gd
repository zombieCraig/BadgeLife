extends Node

const SAVE_FILE = "res://saves.dat"

enum GAME_STATES { TITLE, NEW_GAME, CONTINUE, IN_GAME }
var game_state = null

var current_chapter = "1"
var chapters = { "1": { "title":  "First Convention - PrimeCon",
						"map": "res://Levels/PrimeCon.tmx"
						}
				}

var saves = []

# For now using a global hash for the player data
# "last_save_on"
# "last_save_pos"
var player = { "name": "Hacker",
				"guile": 1,
				"mental": 1,
				"power": 1
			}

# Global method to block player input (so they don't move
var block_player_input = false

# Simple shorthand to change scenes
func change_scene(new_scene):
	get_tree().change_scene(new_scene)

func save_game():
	var save_record = { "name": player["name"], 
						"last_save_on": OS.get_unix_time(), 
						"chapter": current_chapter }
	save_record["player"] = player
	saves.append(save_record)
	var saveFile = File.new()
	saveFile.open_encrypted_with_pass(SAVE_FILE, File.WRITE, "Lulz")
	saveFile.store_line(to_json(saves))
	saveFile.close()

func load_saves():
	var saveFile = File.new()
	if !saveFile.file_exists(SAVE_FILE):
		return
	saveFile.open_encrypted_with_pass(SAVE_FILE, File.READ, "Lulz")
	saves = from_json(saveFile.get_line())
	saveFile.close()

