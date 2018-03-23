extends Node2D

const TS_NPC_GID = 1118 # NPC Tileset GID
const TS_SPECIAL_NPC_GID = 1119

const CUTFRAME_SPEED = 0.4

var CharacterArea # Area of the map to add players and NPCs
var hide_cutscene = false # For end of animation
var player = null # Player object

func cutscene_start():
	$LeftFrame.show()
	$RightFrame.show()
	var panel_size = $LeftFrame.get("rect_size")
	var vtrans = get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	var vsize = get_viewport_rect().size
	var top_right = Vector2((vsize.x / 2) + top_left.x, top_left.y)
	$FrameTween.interpolate_property($LeftFrame, "rect_position", Vector2(top_left.x-panel_size.x,top_left.y), Vector2(top_left.x,top_left.y), CUTFRAME_SPEED,Tween.TRANS_SINE,Tween.EASE_IN)
	$FrameTween.interpolate_property($RightFrame, "rect_position", Vector2(top_right.x,top_right.y), Vector2(top_right.x-panel_size.x,top_right.y), CUTFRAME_SPEED,Tween.TRANS_SINE,Tween.EASE_IN)
	$FrameTween.start()
	hide_cutscene = false

func cutscene_stop():
	var panel_size = $LeftFrame.get("rect_size")
	var vtrans = get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	var vsize = get_viewport_rect().size
	var top_right = Vector2((vsize.x / 2) + top_left.x, top_left.y)
	$FrameTween.interpolate_property($LeftFrame, "rect_position", Vector2(top_left.x,top_left.y), Vector2(top_left.x-panel_size.x,top_left.y), CUTFRAME_SPEED,Tween.TRANS_SINE,Tween.EASE_IN)
	$FrameTween.interpolate_property($RightFrame, "rect_position", Vector2(top_right.x-panel_size.x,top_right.y), Vector2(top_right.x,top_right.y), CUTFRAME_SPEED,Tween.TRANS_SINE,Tween.EASE_IN)
	$FrameTween.start()
	hide_cutscene = true

# Fetches an NPC by name, return null if not found
func get_npc_by_name(npc_name):
	for character in CharacterArea.get_children():
		if character.npc_name.length() > 0 and character.npc_name == npc_name:
			return character
	return null

# Uses the maps navigation area to create simple path from one point to another
func get_navigation_path(from, to):
	var p = $Map.get_simple_path(from, to, true)
	print("DEBUG: get_nav_path =",p)
	var path = Array(p)
	path.invert()
	return path

# Looks up an object by name and returns it
func get_object(obj_name):
	for obj in $Map.get_child(0).get_node("Objects").get_children():
		if obj.name == obj_name:
			return obj
	return null

# Requires the map is loaded with Objects/SpawnPoint
# Returns the position of spawn point as Vector2()
# Return null on failure
func get_spawn_point():
	if $Map.get_child_count() > 0:
		if $Map.get_child(0).has_node("Objects"):
			if $Map.get_child(0).has_node("Objects/SpawnPoint"):
				return $Map.get_child(0).get_node("Objects/SpawnPoint").position
	return null

# Loads the main character, returns true on success
func init_character_area():
	var loaded = false
	var spawn_pos = get_spawn_point()
	if spawn_pos:
		CharacterArea = YSort.new()
		$Map.get_child(0).add_child(CharacterArea)
		player = load("res://Scenes/Character/Player/Player.tscn").instance()
		if $Map.get_child(0).get_node("Objects/SpawnPoint").has_meta("face_dir"):
			match $Map.get_child(0).get_node("Objects/SpawnPoint").get_meta("face_dir"):
				"left":
					player.set_face_dir(player.FACE_LEFT)
				"right":
					player.set_face_dir(player.FACE_RIGHT)
				"up":
					player.set_face_dir(player.FACE_UP)
				"down":
					player.set_face_dir(player.FACE_DOWN)
		CharacterArea.add_child(player)
		player.position = spawn_pos
		var camera = Camera2D.new()
		player.add_child(camera)
		camera.set("name", "Camera")
		camera.set("current", true)
		camera.set("zoom", Vector2(0.5, 0.5))
		loaded = true 
	return loaded

func load_npcs():
	for obj in $Map.get_child(0).get_node("Objects").get_children():
		if obj.has_meta("gid") and obj.get_meta("gid") == TS_NPC_GID:
			var npc = load("res://Scenes/Character/NPCs/NPC.tscn").instance()
			if obj.has_meta("doesnt_move"):
				npc.idle_movement = !obj.get_meta("doesnt_move")
			if obj.has_meta("face_dir"):
				var face_dir = obj.get_meta("face_dir")
				if face_dir == "left":
					npc.set_face_dir(npc.FACE_LEFT)
				elif face_dir == "right":
					npc.set_face_dir(npc.FACE_RIGHT)
				elif face_dir == "up":
					npc.set_face_dir(npc.FACE_UP)
				elif face_dir == "down":
					npc.set_face_dir(npc.FACE_DOWN)
			if obj.has_meta("npc_name"):
				npc.npc_name = obj.get_meta("npc_name")
			if obj.has_meta("msg"):
				npc.msg = obj.get_meta("msg")
			npc.random_mob = true
			CharacterArea.add_child(npc)
			npc.position = obj.position
			obj.visible = false

# Special NPCs have a unique gid and the npc_name much match the scene name
func load_special_npcs():
	for obj in $Map.get_child(0).get_node("Objects").get_children():
		if obj.has_meta("gid") and obj.get_meta("gid") == TS_SPECIAL_NPC_GID:
			if obj.has_meta("npc_name"):
				var npc = obj.get_meta("npc_name")
				var path = "res://Scenes/Character/NPCs/" + npc + "/" + npc + ".tscn"
				var testFile = File.new()
				if testFile.file_exists(path):
					var special_npc = load(path).instance()
					CharacterArea.add_child(special_npc)
					special_npc.position = obj.position
					obj.visible = false
					if obj.has_meta("msg"):
						special_npc.msg = obj.get_meta("msg")
				else:
					print("Error: Special npc, " + npc + ", not found at " + path)

# Scans the Tiled map for Trigger areas. Tiled poligons with name TriggerXXX of type area
# Supported target triggers:
	# trigger_npc - NPC name that will recieve the trigger when objects enter
func init_triggers():
	for obj in $Map.get_child(0).get_node("Objects").get_children():
		if obj.name.begins_with("Trigger"):
			if obj.has_meta("trigger_npc"):
				var trigger_npc = obj.get_meta("trigger_npc")
				var npc = get_npc_by_name(trigger_npc)
				if npc:
					obj.connect('body_entered', npc, '_triggered', [obj])
				else:
					print("Error: Area trigger npc, " + trigger_npc + ", could not be located on map")
			else:
				print("Error: Tile area missing trigger_npc")

func init_new_game():
	var map = load(global.chapters["1"]["map"]).instance()
	$Map.add_child(map)
	if not init_character_area():
		print_error("Couldn't init player on map!")
		return
	load_npcs()
	load_special_npcs()
	init_triggers()

# If multiple save states, we assume the correct one has already
# been selected
func restore_game():
	pass

func _ready():
	match global.game_state:
		global.NEW_GAME:
			init_new_game()
		global.CONTINUE:
			restore_game()

func _on_FrameTween_tween_completed( object, key ):
	if hide_cutscene:
		$LeftFrame.hide()
		$RightFrame.hide()
