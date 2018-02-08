extends "res://Scenes/Character/Character.gd"

const IDLE_WALK_TIME = 0.4

export var random_mob = false
export var idle_movement = false
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

func walk(walk_time):
	max_speed = MAX_WALK_SPEED
	walking = true
	var dir = randi() % 4
	if dir == 0:
		walk_direction = Vector2(-1, 0)
	elif dir == 1:
		walk_direction = Vector2(1, 0)
	elif dir == 2:
		walk_direction = Vector2(0, -1)
	else:
		walk_direction = Vector2(0, 1)
	$WalkTimer.set("wait_time", walk_time)
	$WalkTimer.start()
	input_direction = walk_direction

# Function for interacting with this NPC
func interact():
	if $Dialog.visible:
		return
	busy = true
	var msg = random_speech[randi() % random_speech.size() ]
	$Dialog.set_text(msg)
	$Dialog.panel_show()
	global.block_player_input = true

func set_idle_timer():
	$IdleTimer.set("wait_time", 1 + randf() * 2)
	$IdleTimer.start()

func _ready():
	if random_mob:
		randomize()
		randomize_look()
		face_random_dir()
		idle_movement = true
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
