extends Node2D

const TS_NPC_GID = 1118 # NPC Tileset GID

var CharacterArea # Area of the map to add players and NPCs

# Requires the map is loaded with Objects/SpawnPoint
# Returns the position of spawn point as Vector2()
# Return null on failure
func get_spawn_point():
	if $Map.get_child_count() > 0:
		if $Map.get_child(0).has_node("Objects"):
			if $Map.get_child(0).has_node("Objects/SpawnPoint"):
				return $Map.get_child(0).get_node("Objects/SpawnPoint").position
	return null

func init_character_area():
	var spawn_pos = get_spawn_point()
	if spawn_pos:
		CharacterArea = YSort.new()
		$Map.get_child(0).add_child(CharacterArea)
		var player = load("res://Scenes/Character/Player/Player.tscn").instance()
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
		camera.set("current", true)
		camera.set("zoom", Vector2(0.5, 0.5))

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

func init_new_game():
	var map = load(global.chapters["1"]["map"]).instance()
	$Map.add_child(map)
	init_character_area()
	load_npcs()

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