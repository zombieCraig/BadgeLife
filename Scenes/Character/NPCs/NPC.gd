extends "res://Scenes/Character/Character.gd"

const IDLE_WALK_TIME = 0.4

export var random_mob = false
export var idle_movement = true
export var msg = "" # Message to say if asked something
var busy = false # If the NPC is busy with an action (like talking)
var walking = false
var walk_direction = Vector2()

# Not really standard but not too crazy.  Decent for clothing options
var standard_colors = [ Color(.06, .25, .21), Color(.22, .52, .90), Color(.18, .80, .42),
	Color(.70, .79, .06), Color(.46, .74, .67), Color(.18, .35, .31) ]

# Some random generic sayings
var random_speech = [ "Hey there", "What's up?", "So what's going on?", "Do I know you?", "This is my first con" ]

func _random_gender():
	base_gender = genders[randi() % genders.size() ]

func _random_skintone():
	base_skintone = skin_tones[randi() % skin_tones.size() ]

func _random_hair():
	if randi() % 20 == 0:  # 1 in 20 of being bald
		base_hair = null
	else:
		base_hair = hair_styles[randi() % hair_styles.size() ]
		base_hair_color = Color(randf(), randf(), randf() )
		$Pivot/Body/Hair.set("self_modulate", base_hair_color)

func _random_legwear():
	base_legwear_color = standard_colors[randi() % standard_colors.size() ]
	$Pivot/Body/Legs.set("modulate", base_legwear_color)

func _random_torsowear():
	base_torsowear_color = standard_colors[randi() % standard_colors.size() ]
	$Pivot/Body/Torso.set("modulate", base_torsowear_color)

func _random_footwear():
	if randi() % 25 == 0:
		base_footwear = null

func randomize_look():
	_random_gender()
	_random_skintone()
	_random_hair()
	_random_legwear()
	_random_torsowear()
	_random_footwear()
	update_body()

func face_random_dir():
	var dir = randi() % 4
	if dir == 0:
		last_move_direction = Vector2(-1, 0)
	elif dir == 1:
		last_move_direction = Vector2(1, 0)
	elif dir == 2:
		last_move_direction = Vector2(0, -1)
	else:
		last_move_direction = Vector2(0, 1)

# Checks area next to NPC, returns vectors where something is NOT present
func check_surroundings():
	var open_area = []
	enable_raycasting()
	$RayCast2D.set("cast_to", Vector2(0, -50)) # UP
	$RayCast2D.force_raycast_update()
	if not $RayCast2D.is_colliding():
		open_area.append(Vector2(0,-1))
	$RayCast2D.set("cast_to", Vector2(0, 50)) # DOWN
	$RayCast2D.force_raycast_update()
	if not $RayCast2D.is_colliding():
		open_area.append(Vector2(0,1))
	$RayCast2D.set("cast_to", Vector2(-50, 0)) # LEFT
	$RayCast2D.force_raycast_update()
	if not $RayCast2D.is_colliding():
		open_area.append(Vector2(-1,0))
	$RayCast2D.set("cast_to", Vector2(50, 0)) # RIGHT
	$RayCast2D.force_raycast_update()
	if not $RayCast2D.is_colliding():
		open_area.append(Vector2(1,0))
	disable_raycasting()
	return open_area

func walk(walk_time):
	max_speed = MAX_WALK_SPEED
	walking = true
	var open_walk_directions = check_surroundings()
	if open_walk_directions.size() == 0:
		return
	walk_direction = open_walk_directions[randi() % open_walk_directions.size()]
	$WalkTimer.set("wait_time", walk_time)
	$WalkTimer.start()
	input_direction = walk_direction

# Faces the player
func face_player():
	if has_node("../Player/Pivot/Body"):
		var player_facing = get_node("../Player/Pivot/Body").frame
		match player_facing:
			FRAME_LEFT:
				set_face_dir(FACE_RIGHT)
			FRAME_RIGHT:
				set_face_dir(FACE_LEFT)
			FRAME_UP:
				set_face_dir(FACE_DOWN)
			FRAME_DOWN:
				set_face_dir(FACE_UP)

func enable_raycasting():
	$RayCast2D.set("enabled", true)

func disable_raycasting():
	$RayCast2D.set("enabled", false)

# Syncs raycast to facing direction
func set_raycast():
	if last_move_direction.y == -1:
		$RayCast2D.set("cast_to", Vector2(0, -50))
	elif last_move_direction.y == 1:
		$RayCast2D.set("cast_to", Vector2(0, 50))
	elif last_move_direction.x == -1:
		$RayCast2D.set("cast_to", Vector2(-50, 0))
	elif last_move_direction.x == 1:
		$RayCast2D.set("cast_to", Vector2(50, 0))

# Function for interacting with this NPC
func interact():
	if $Dialog.visible:
		return
	busy = true
	if msg.length() > 0:
		$Dialog.resize(Vector2(230, 150), $Dialog.TACT_BOTTOM)
		$Dialog.set_text(msg)
	else:
		var random_msg = random_speech[randi() % random_speech.size() ]
		$Dialog.set_text(random_msg)
	$Dialog.panel_show()
	face_player()
	global.block_player_input = true

func set_idle_timer():
	$IdleTimer.set("wait_time", 1 + randf() * 2)
	$IdleTimer.start()

func _ready():
	if random_mob:
		randomize()
		randomize_look()
		face_random_dir()
	if idle_movement:
		set_idle_timer()
		add_to_group('bumpable')

func _on_IdleTimer_timeout():
	if not busy:
		if not walking:
			if randi() % 4 == 0:
				walk(IDLE_WALK_TIME)
			else:
				face_random_dir()
	set_idle_timer()

func _on_WalkTimer_timeout():
	walking = false
	input_direction = Vector2()

func _on_Dialog_dialog_completed():
	global.block_player_input = false
	busy = false
